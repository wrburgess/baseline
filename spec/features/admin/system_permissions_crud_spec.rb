require "rails_helper"

RSpec.describe "Admin System Permissions CRUD", type: :feature do
  include_context "authorized_admin_setup"
  let(:authorized_resource_name) { "SystemPermission" }

  describe "index page" do
    let!(:permission_1) { create(:system_permission, name: "User Create") }
    let!(:permission_2) { create(:system_permission, name: "User Delete") }

    it "displays a list of system permissions" do
      visit "/admin/system_permissions"

      expect(page).to have_content("User Create")
      expect(page).to have_content("User Delete")
    end
  end

  describe "show page" do
    let!(:target_permission) { create(:system_permission, name: "Test Permission", description: "A test permission") }

    it "displays system permission details" do
      visit "/admin/system_permissions/#{target_permission.id}"

      expect(page).to have_content("Test Permission")
      expect(page).to have_content("A test permission")
    end
  end

  describe "new page" do
    it "displays the new system permission form" do
      visit "/admin/system_permissions/new"

      expect(page).to have_field("Name")
      expect(page).to have_button("Submit")
    end
  end

  describe "edit page" do
    let!(:target_permission) { create(:system_permission, name: "Original Permission") }

    it "displays the edit system permission form with current values" do
      visit "/admin/system_permissions/#{target_permission.id}/edit"

      expect(page).to have_field("Name", with: "Original Permission")
      expect(page).to have_button("Submit")
    end
  end
end
