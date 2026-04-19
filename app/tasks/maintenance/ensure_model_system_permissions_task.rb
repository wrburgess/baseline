# Maintenance task to ensure SystemPermissions exist for all models
#
# This task scans all ActiveRecord models in app/models and ensures that
# standard CRUD permissions (create, index, show, edit, update, copy) exist
# for each model. It then associates these permissions with the "System Management" role.
#
# Usage:
#   bin/rails maintenance_tasks:run[Maintenance::EnsureModelSystemPermissionsTask]
#
# The task will:
# 1. Find all ActiveRecord models in the application
# 2. Check if SystemPermissions exist for standard operations
# 3. Create missing permissions with proper naming and abbreviations
# 4. Associate new permissions with the System Management role
# 5. Skip permissions that already exist
#
module Maintenance
  class EnsureModelSystemPermissionsTask < MaintenanceTasks::Task
    no_collection

    def process
      system_management_role = find_system_management_role
      return unless system_management_role

      created_permissions = []

      models_to_scan.each do |model_class|
        resource = model_class.name

        standard_operations.each do |operation|
          permission = ensure_system_permission_exists(resource, operation)
          if permission
            associate_with_role(permission, system_management_role)
            created_permissions << permission if permission.previously_new_record?
          end
        end
      end

      puts "Task completed. Created #{created_permissions.count} new permissions."
      created_permissions.each do |permission|
        puts "  - #{permission.name}"
      end
    end

    private

    def find_system_management_role
      role = SystemRole.find_by(name: "System Management")
      unless role
        puts "ERROR: System Management role not found. Please create it first."
        return nil
      end
      role
    end

    def models_to_scan
      # Get all model files from app/models
      model_files = Dir[Rails.root.join("app", "models", "*.rb")]

      models = model_files.map do |file|
        # Extract class name from filename
        class_name = File.basename(file, ".rb").camelize

        # Skip ApplicationRecord and other base classes
        next if [ "ApplicationRecord" ].include?(class_name)

        # Try to constantize the class
        begin
          class_name.constantize
        rescue NameError => e
          puts "Warning: Could not load model #{class_name}: #{e.message}"
          nil
        end
      end.compact

      # Filter to only include ActiveRecord models
      models.select { |klass| klass < ApplicationRecord }
    end

    def standard_operations
      [
        SystemOperations::CREATE,
        SystemOperations::INDEX,
        SystemOperations::SHOW,
        SystemOperations::EDIT,
        SystemOperations::UPDATE,
        SystemOperations::COPY
      ]
    end

    def ensure_system_permission_exists(resource, operation)
      name = "#{resource} #{operation.upcase}"

      # Create better abbreviations
      abbreviation = case resource
      when "Organization"
                       "ORG #{operation.upcase}"
      when "User"
                       "USR #{operation.upcase}"
      when "Contact"
                       "CON #{operation.upcase}"
      when "OrganizationUser"
                       "OU #{operation.upcase}"
      when "SystemPermission"
                       "SP #{operation.upcase}"
      when "SystemRole"
                       "SR #{operation.upcase}"
      when "SystemGroup"
                       "SG #{operation.upcase}"
      when "ExternalApplication"
                       "EA #{operation.upcase}"
      when "InboundRequestLog"
                       "IRL #{operation.upcase}"
      else
                       # For other models, use first letter of each capital letter
                       resource_abbrev = resource.scan(/[A-Z]/).join
                       "#{resource_abbrev} #{operation.upcase}"
      end

      # Check if permission already exists
      existing_permission = SystemPermission.find_by(resource: resource, operation: operation)

      if existing_permission
        puts "Permission already exists: #{existing_permission.name}"
        return existing_permission
      end

      # Create new permission
      permission = SystemPermission.create!(
        name: name,
        resource: resource,
        operation: operation,
        abbreviation: abbreviation
      )

      puts "Created new permission: #{permission.name}"
      permission
    end

    def associate_with_role(permission, role)
      # Check if already associated
      return if permission.system_roles.include?(role)

      permission.system_roles << role
      puts "  Associated with #{role.name} role"
    end
  end
end
