require "rails_helper"

RSpec.describe "Admin Data Logs", type: :feature do
  include_context "authorized_admin_setup"
  let(:authorized_resource_name) { "DataLog" }

  describe "index page" do
    let!(:data_log_1) { create(:data_log, operation: "create", note: "Created a record") }
    let!(:data_log_2) { create(:data_log, operation: "update", note: "Updated a record") }

    it "displays a list of data logs" do
      visit "/admin/data_logs"

      expect(page).to have_content("create")
      expect(page).to have_content("update")
    end
  end

  describe "show page" do
    let!(:target_log) { create(:data_log, operation: "delete", note: "Deleted the item") }

    it "displays data log details" do
      visit "/admin/data_logs/#{target_log.id}"

      expect(page).to have_content(/delete/i)
      expect(page).to have_content("Deleted the item")
    end
  end
end
