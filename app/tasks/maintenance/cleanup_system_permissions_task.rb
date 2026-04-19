# Maintenance task to clean up and standardize SystemPermission records
#
# This task ensures data integrity and consistency across SystemPermission records by:
# 1. Identifying and merging duplicate resource/operation combinations
# 2. Standardizing naming conventions (e.g., "Organization CREATE")
# 3. Ensuring proper abbreviations exist (e.g., "ORG CRE")
# 4. Preserving all SystemRole associations during merges
# 5. Cleaning up orphaned or malformed records
#
# Usage:
#   bin/rails maintenance_tasks:run[Maintenance::CleanupSystemPermissionsTask]
#
module Maintenance
  class CleanupSystemPermissionsTask < MaintenanceTasks::Task
    no_collection

    def process
      fixed_permissions = []
      merged_permissions = []
      deleted_count = 0

      puts "Starting SystemPermission cleanup..."

      # Step 1: Fix naming and abbreviations for all permissions
      SystemPermission.find_each do |permission|
        fixed_permissions << permission if fix_permission_format(permission)
      end

      # Step 2: Find and merge duplicates
      duplicate_groups = find_duplicate_groups

      duplicate_groups.each do |group|
        primary_permission = merge_duplicate_permissions(group)
        if primary_permission
          merged_permissions << primary_permission
          deleted_count += (group.size - 1)
        end
      end

      # Step 3: Clean up any permissions with missing required fields
      invalid_permissions = SystemPermission.where(
        "resource IS NULL OR resource = '' OR operation IS NULL OR operation = '' OR name IS NULL OR name = ''"
      )

      invalid_permissions.each do |permission|
        puts "Removing invalid permission with ID #{permission.id}: #{permission.inspect}"
        permission.destroy
        deleted_count += 1
      end

      puts "Task completed successfully!"
      puts "- Fixed #{fixed_permissions.count} permission formats"
      puts "- Merged #{merged_permissions.count} duplicate groups"
      puts "- Deleted #{deleted_count} duplicate/invalid records"

      if fixed_permissions.any?
        puts "\nFixed permissions:"
        fixed_permissions.each { |p| puts "  - #{p.name} (#{p.abbreviation})" }
      end

      return unless merged_permissions.any?

      puts "\nMerged duplicate groups:"
      merged_permissions.each { |p| puts "  - #{p.resource} #{p.operation}" }
    end

    private

    def find_duplicate_groups
      # Find all resource/operation combinations that have multiple records
      duplicate_keys = SystemPermission.group(:resource, :operation)
                                       .having("count(*) > 1")
                                       .count
                                       .keys

      duplicate_groups = []
      duplicate_keys.each do |resource, operation|
        permissions = SystemPermission.where(resource: resource, operation: operation).to_a
        duplicate_groups << permissions if permissions.size > 1
      end

      duplicate_groups
    end

    def merge_duplicate_permissions(duplicate_permissions)
      return nil if duplicate_permissions.empty?

      # Choose the "best" permission as primary (most complete record)
      primary = choose_primary_permission(duplicate_permissions)
      duplicates = duplicate_permissions - [ primary ]

      puts "Merging #{duplicate_permissions.size} duplicates for #{primary.resource} #{primary.operation}"

      # Fix the primary permission's format
      fix_permission_format(primary)

      # Collect all unique SystemRole associations
      all_roles = duplicate_permissions.flat_map(&:system_roles).uniq

      SystemPermission.transaction do
        # Remove all current associations for primary
        primary.system_role_system_permissions.destroy_all

        # Associate primary with all collected roles
        all_roles.each do |role|
          SystemRoleSystemPermission.create!(
            system_role: role,
            system_permission: primary
          )
        end

        # Remove duplicates (this will cascade delete their associations)
        duplicates.each do |duplicate|
          puts "  Removing duplicate ID #{duplicate.id}: #{duplicate.name}"
          duplicate.destroy
        end

        puts "  Preserved #{all_roles.count} role associations on primary record"
      end

      primary
    end

    def choose_primary_permission(permissions)
      # Choose the permission with the most complete/correct data
      permissions.max_by do |permission|
        score = 0
        score += 10 if permission.name.present?
        score += 10 if permission.abbreviation.present?
        score += 5 if permission.description.present?
        score += 5 if permission.notes.present?
        score += 20 if has_correct_name_format?(permission)
        score += 15 if has_correct_abbreviation_format?(permission)
        score += permission.system_roles.count # Prefer the one with more role associations
        score
      end
    end

    def fix_permission_format(permission)
      return false unless permission.resource.present? && permission.operation.present?

      # Generate correct name and abbreviation
      correct_name = generate_correct_name(permission.resource, permission.operation)
      correct_abbreviation = generate_correct_abbreviation(permission.resource, permission.operation)

      changes_made = false

      if permission.name != correct_name
        puts "Fixing name: '#{permission.name}' → '#{correct_name}'"
        permission.name = correct_name
        changes_made = true
      end

      if permission.abbreviation != correct_abbreviation
        puts "Fixing abbreviation: '#{permission.abbreviation}' → '#{correct_abbreviation}'"
        permission.abbreviation = correct_abbreviation
        changes_made = true
      end

      permission.save! if changes_made

      changes_made
    end

    def generate_correct_name(resource, operation)
      "#{resource} #{operation.upcase}"
    end

    def generate_correct_abbreviation(resource, operation)
      resource_abbrev = case resource
      when "Organization"
                          "ORG"
      when "User"
                          "USR"
      when "Contact"
                          "CON"
      when "OrganizationUser"
                          "OU"
      when "SystemPermission"
                          "SP"
      when "SystemRole"
                          "SR"
      when "SystemGroup"
                          "SG"
      when "ExternalApplication"
                          "EA"
      when "InboundRequestLog"
                          "IRL"
      when "DataLog"
                          "DL"
      when "MaintenanceTasksRun"
                          "MTR"
      when "SystemGroupSystemRole"
                          "SGSR"
      when "SystemGroupUser"
                          "SGU"
      when "SystemRoleSystemPermission"
                          "SRSP"
      else
                          # For other models, use first letter of each capital letter
                          resource.scan(/[A-Z]/).join
      end

      operation_abbrev = case operation.downcase
      when "create"
                           "CRE"
      when "index"
                           "IDX"
      when "show"
                           "SHO"
      when "edit"
                           "EDT"
      when "update"
                           "UPD"
      when "destroy"
                           "DEL"
      when "copy"
                           "CPY"
      when "archive"
                           "ARC"
      when "unarchive"
                           "UNA"
      when "collection_export_xlsx"
                           "CEX"
      when "member_export_xlsx"
                           "MEX"
      when "import"
                           "IMP"
      when "export_example"
                           "EEX"
      when "new"
                           "NEW"
      when "share"
                           "SHA"
      else
                           operation.upcase.slice(0, 3)
      end

      "#{resource_abbrev} #{operation_abbrev}"
    end

    def has_correct_name_format?(permission)
      return false unless permission.name.present?
      return false unless permission.resource.present? && permission.operation.present?

      expected_name = generate_correct_name(permission.resource, permission.operation)
      permission.name == expected_name
    end

    def has_correct_abbreviation_format?(permission)
      return false unless permission.abbreviation.present?
      return false unless permission.resource.present? && permission.operation.present?

      expected_abbreviation = generate_correct_abbreviation(permission.resource, permission.operation)
      permission.abbreviation == expected_abbreviation
    end
  end
end
