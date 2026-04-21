module Maintenance
  class ImportSystemPermissionsTask < MaintenanceTasks::Task
    no_collection

    def process
      SystemPermission.delete_all
      SystemRole.delete_all
      SystemGroup.delete_all
      SystemRoleSystemPermission.delete_all
      SystemGroupSystemRole.delete_all
      SystemGroupUser.delete_all

      xlsx = Roo::Spreadsheet.open("#{Rails.root}/db/source/system_permissions.xlsx")

      create_system_groups(xlsx.sheet("system_groups"))
      create_system_roles(xlsx.sheet("system_roles"))
      associate_system_groups_and_roles(xlsx.sheet("system_groups"))
      process_system_permissions(xlsx.sheet("system_permissions"))
      assign_users(xlsx.sheet("user_assignments"))
    end

    private

    def create_system_groups(sheet)
      puts "Processing system groups..."
      sheet.each(name: "name", associated_roles: "associated_roles") do |row|
        next if row[:name] == "name" # Skip header row

        SystemGroup.find_or_create_by(name: row[:name])
      end
    end

    def create_system_roles(sheet)
      puts "Create system roles..."
      sheet.each(name: "name", abbreviation: "abbreviation") do |row|
        next if row[:name] == "name" # Skip header row

        SystemRole.find_or_create_by(name: row[:name], abbreviation: row[:abbreviation])
      end
    end

    def associate_system_groups_and_roles(sheet)
      puts "Associating system groups..."
      sheet.each(name: "name", associated_roles: "associated_roles") do |row|
        next if row[:name] == "name" # Skip header row

        system_group = SystemGroup.find_or_create_by(name: row[:name])

        associated_roles = row[:associated_roles].to_s.split(",").map(&:strip)
        associated_roles.each do |role_abbreviation|
          system_role = SystemRole.find_by(abbreviation: role_abbreviation)
          SystemGroupSystemRole.find_or_create_by(system_group:, system_role:) if system_role
        end
      end
    end

    def process_system_permissions(sheet)
      puts "Processing system permissions..."
      sheet.each(resource: "resource", operation: "operation", roles: "roles") do |row|
        next if row[:resource] == "resource" # Skip header row

        system_permission = SystemPermission.find_or_create_by(name: "#{row[:resource]} #{row[:operation].upcase}", resource: row[:resource], operation: row[:operation])
        system_permission_index = SystemPermission.find_or_create_by(name: "#{row[:resource]} #{row[:operation].upcase}", resource: row[:resource], operation: "index") if row[:operation] == "show"
        system_permission_export_example = SystemPermission.find_or_create_by(name: "#{row[:resource]} #{row[:operation].upcase}", resource: row[:resource], operation: "export_example") if row[:operation] == "import"

        roles = row[:roles].to_s.split(",").map(&:strip)
        roles.each do |name|
          system_role = SystemRole.find_by(name:)
          SystemRoleSystemPermission.find_or_create_by(system_permission: system_permission, system_role: system_role) if system_role
          SystemRoleSystemPermission.find_or_create_by(system_permission: system_permission_index, system_role: system_role) if system_role && system_permission_index
          SystemRoleSystemPermission.find_or_create_by(system_permission: system_permission_export_example, system_role: system_role) if system_role && system_permission_export_example
        end
      end
    end

    def assign_users(sheet)
      puts "Processing system permissions..."
      sheet.each(email: "email", system_groups: "system_groups") do |row|
        next if row[:email] == "email" # Skip header row

        user = User.find_by(email: row[:email])

        system_groups = row[:system_groups].to_s.split(",").map(&:strip)
        system_groups.each do |system_group_name|
          system_group = SystemGroup.find_by(name: system_group_name)
          SystemGroupUser.find_or_create_by(system_group:, user:)
        end
      end
    end
  end
end
