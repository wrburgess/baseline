# Provides a fully-authorized admin user for feature specs.
# Creates real DB records because Capybara runs in a separate process
# and cannot share RSpec stubs.
#
# Permission behavior is tested exhaustively in spec/policies/.
# This context exists solely to get past authorization checks
# so feature specs can test UI behavior.
#
# Usage:
#   include_context "authorized_admin_setup"
#   let(:authorized_resource_name) { "SystemGroup" }
#
RSpec.shared_context "authorized_admin_setup" do
  let(:authorized_resource_name) { raise "You must define let(:authorized_resource_name) when using authorized_admin_setup" }
  let(:user) { create(:user) }
  let(:auth_system_group) { create(:system_group) }
  let(:auth_system_role) { create(:system_role) }

  before do
    %w[
      index show new create edit update destroy
      archive unarchive collection_export_xlsx member_export_xlsx copy
    ].each do |operation|
      permission = create(:system_permission,
        name: "#{authorized_resource_name} #{operation.titleize}",
        resource: authorized_resource_name,
        operation: operation)
      auth_system_role.system_permissions << permission
    end

    auth_system_group.system_roles << auth_system_role
    auth_system_group.users << user

    login_as(user, scope: :user)
  end
end
