require "rails_helper"

RSpec.describe "Admin Notification Subscriptions CRUD", type: :feature do
  include_context "authorized_admin_setup"
  let(:authorized_resource_name) { "NotificationSubscription" }

  describe "index page" do
    let!(:topic) { create(:notification_topic) }
    let!(:subscriber) { create(:user, first_name: "Subscriber", last_name: "One") }
    let!(:subscription_1) { create(:notification_subscription, notification_topic: topic, user: subscriber, distribution_method: "email") }

    it "displays a list of notification subscriptions" do
      visit "/admin/notification_subscriptions"

      expect(page).to have_content(/email/i)
    end
  end

  describe "show page" do
    let!(:topic) { create(:notification_topic, name: "Test Topic") }
    let!(:subscriber) { create(:user, first_name: "Test", last_name: "Subscriber") }
    let!(:target_subscription) { create(:notification_subscription, notification_topic: topic, user: subscriber) }

    it "displays notification subscription details" do
      visit "/admin/notification_subscriptions/#{target_subscription.id}"

      expect(page).to have_content("Test Topic")
      expect(page).to have_content("Test Subscriber")
    end
  end

  describe "new page" do
    it "displays the new notification subscription form" do
      visit "/admin/notification_subscriptions/new"

      expect(page).to have_button("Submit")
    end
  end

  describe "edit page" do
    let!(:topic) { create(:notification_topic) }
    let!(:subscriber) { create(:user) }
    let!(:target_subscription) { create(:notification_subscription, notification_topic: topic, user: subscriber, distribution_frequency: "immediate") }

    it "displays the edit notification subscription form" do
      visit "/admin/notification_subscriptions/#{target_subscription.id}/edit"

      expect(page).to have_button("Submit")
    end
  end
end
