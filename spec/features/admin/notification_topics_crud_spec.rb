require "rails_helper"

RSpec.describe "Admin Notification Topics CRUD", type: :feature do
  include_context "authorized_admin_setup"
  let(:authorized_resource_name) { "NotificationTopic" }

  describe "index page" do
    let!(:topic_1) { create(:notification_topic, name: "User Created", key: "user.created") }
    let!(:topic_2) { create(:notification_topic, name: "Order Placed", key: "order.placed") }

    it "displays a list of notification topics" do
      visit "/admin/notification_topics"

      expect(page).to have_content("User Created")
      expect(page).to have_content("Order Placed")
    end
  end

  describe "show page" do
    let!(:target_topic) { create(:notification_topic, name: "Test Topic", key: "test.topic", description: "A test topic") }

    it "displays notification topic details" do
      visit "/admin/notification_topics/#{target_topic.id}"

      expect(page).to have_content("Test Topic")
      expect(page).to have_content("test.topic")
    end
  end

  describe "new page" do
    it "displays the new notification topic form" do
      visit "/admin/notification_topics/new"

      expect(page).to have_field("Name")
      expect(page).to have_field("Key")
      expect(page).to have_button("Submit")
    end
  end

  describe "edit page" do
    let!(:target_topic) { create(:notification_topic, name: "Original Topic", key: "original.topic") }

    it "displays the edit notification topic form with current values" do
      visit "/admin/notification_topics/#{target_topic.id}/edit"

      expect(page).to have_field("Name", with: "Original Topic")
      expect(page).to have_field("Key", with: "original.topic")
      expect(page).to have_button("Submit")
    end
  end
end
