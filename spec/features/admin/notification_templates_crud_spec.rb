require "rails_helper"

RSpec.describe "Admin Notification Templates CRUD", type: :feature do
  include_context "authorized_admin_setup"
  let(:authorized_resource_name) { "NotificationTemplate" }

  describe "index page" do
    let!(:topic) { create(:notification_topic) }
    let!(:template_1) { create(:notification_template, notification_topic: topic, distribution_method: "email") }
    let!(:template_2) { create(:notification_template, notification_topic: topic, distribution_method: "sms") }

    it "displays a list of notification templates" do
      visit "/admin/notification_templates"

      expect(page).to have_content(/email/i)
      expect(page).to have_content(/sms/i)
    end
  end

  describe "show page" do
    let!(:topic) { create(:notification_topic, name: "Test Topic") }
    let!(:target_template) { create(:notification_template, notification_topic: topic, subject_template: "Test Subject") }

    it "displays notification template details" do
      visit "/admin/notification_templates/#{target_template.id}"

      expect(page).to have_content("Test Subject")
    end
  end

  describe "new page" do
    it "displays the new notification template form" do
      visit "/admin/notification_templates/new"

      expect(page).to have_field("Subject template")
      expect(page).to have_button("Submit")
    end
  end

  describe "edit page" do
    let!(:topic) { create(:notification_topic) }
    let!(:target_template) { create(:notification_template, notification_topic: topic, subject_template: "Original Subject") }

    it "displays the edit notification template form with current values" do
      visit "/admin/notification_templates/#{target_template.id}/edit"

      expect(page).to have_field("Subject template", with: "Original Subject")
      expect(page).to have_button("Submit")
    end
  end
end
