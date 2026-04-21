module Maintenance
  class SystemPermissionsBulkCreateTask < MaintenanceTasks::Task
    no_collection

    attribute :resource_name, :string
    attribute :system_role_name, :string

    def process
      operations.each do |operation|
        system_role = SystemRole.find_by(name: system_role_name)

        system_permission = SystemPermission.find_or_create_by(name: "#{resource_name.titleize} #{operation.upcase}") do |permission|
          permission.resource = resource_name
          permission.operation = operation
        end

        system_permission.system_roles << system_role
      end
    end

    private

    def operations
      [
        SystemOperations::ARCHIVE,
        SystemOperations::CREATE,
        SystemOperations::DESTROY,
        SystemOperations::EDIT,
        SystemOperations::INDEX,
        SystemOperations::NEW,
        SystemOperations::SHOW,
        SystemOperations::UNARCHIVE,
        SystemOperations::UPDATE
      ]
    end
  end
end
