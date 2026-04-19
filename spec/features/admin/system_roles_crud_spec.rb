require "rails_helper"

RSpec.describe "Admin System Roles CRUD", type: :feature do
  include_context "authorized_admin_setup"
  let(:authorized_resource_name) { "SystemRole" }

  describe "index page" do
    let!(:role_1) { create(:system_role, name: "Administrators") }
    let!(:role_2) { create(:system_role, name: "Editors") }

    it "displays a list of system roles" do
      visit "/admin/system_roles"

      expect(page).to have_content("Administrators")
      expect(page).to have_content("Editors")
    end
  end

  describe "show page" do
    let!(:target_role) { create(:system_role, name: "Test Role", description: "A test role") }

    it "displays system role details" do
      visit "/admin/system_roles/#{target_role.id}"

      expect(page).to have_content("Test Role")
      expect(page).to have_content("A test role")
    end
  end

  describe "new page" do
    it "displays the new system role form" do
      visit "/admin/system_roles/new"

      expect(page).to have_field("Name")
      expect(page).to have_button("Submit")
    end
  end

  describe "edit page" do
    let!(:target_role) { create(:system_role, name: "Original Role") }

    it "displays the edit system role form with current values" do
      visit "/admin/system_roles/#{target_role.id}/edit"

      expect(page).to have_field("Name", with: "Original Role")
      expect(page).to have_button("Submit")
    end
  end
end
