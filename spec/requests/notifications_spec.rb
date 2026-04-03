require "rails_helper"

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:notification) { create(:notification, recipient: user, read: false, message: "Your ticket was updated") }

  describe "GET /notifications" do
    let!(:my_notification) { notification }
    let!(:other_notification) { create(:notification, recipient: other_user, message: "Other user notification") }

    it "lists current user's notifications" do
      sign_in user

      get notifications_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Notifications")
      expect(response.body).to include(my_notification.message)
      expect(response.body).not_to include(other_notification.message)
    end

    it "redirects unauthenticated user" do
      get notifications_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PATCH /notifications/:id/mark_as_read" do
    it "marks one notification as read" do
      sign_in user

      patch mark_as_read_notification_path(notification)

      expect(response).to redirect_to(notifications_path)
      expect(notification.reload.read).to be(true)
    end

    it "prevents marking other user's notification" do
      sign_in other_user

      patch mark_as_read_notification_path(notification)

      expect(response).to have_http_status(:not_found)
      expect(notification.reload.read).to be(false)
    end
  end

  describe "PATCH /notifications/mark_all_as_read" do
    let!(:first_unread) { create(:notification, recipient: user, read: false) }
    let!(:second_unread) { create(:notification, recipient: user, read: false) }
    let!(:other_unread) { create(:notification, recipient: other_user, read: false) }

    it "marks all current user's notifications as read" do
      sign_in user

      patch mark_all_as_read_notifications_path

      expect(response).to redirect_to(notifications_path)
      expect(first_unread.reload.read).to be(true)
      expect(second_unread.reload.read).to be(true)
      expect(other_unread.reload.read).to be(false)
    end
  end
end
