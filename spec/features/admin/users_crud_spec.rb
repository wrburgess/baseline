require "rails_helper"

RSpec.describe "Admin Users CRUD", type: :feature do
  include_context "authorized_admin_setup"
  let(:authorized_resource_name) { "User" }

  describe "index page" do
    let!(:user_1) { create(:user, first_name: "Alice", last_name: "Smith") }
    let!(:user_2) { create(:user, first_name: "Bob", last_name: "Jones") }

    it "displays a list of users" do
      visit "/admin/users"

      expect(page).to have_content("Alice")
      expect(page).to have_content("Bob")
    end
  end

  describe "show page" do
    let!(:target_user) { create(:user, first_name: "Test", last_name: "User", email: "testuser@example.com") }

    it "displays user details" do
      visit "/admin/users/#{target_user.id}"

      expect(page).to have_content("Test")
      expect(page).to have_content("User")
      expect(page).to have_content("testuser@example.com")
    end
  end

  describe "new page" do
    it "displays the new user form" do
      visit "/admin/users/new"

      expect(page).to have_field("Email")
      expect(page).to have_field("First name")
      expect(page).to have_field("Last name")
      expect(page).to have_button("Submit")
    end
  end

  describe "edit page" do
    let!(:target_user) { create(:user, first_name: "Original", last_name: "Name") }

    it "displays the edit user form with current values" do
      visit "/admin/users/#{target_user.id}/edit"

      expect(page).to have_field("First name", with: "Original")
      expect(page).to have_field("Last name", with: "Name")
      expect(page).to have_button("Submit")
    end
  end
end
