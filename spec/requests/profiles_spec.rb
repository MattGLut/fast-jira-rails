require "rails_helper"

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user, first_name: "Avery", last_name: "Stone", email: "avery@example.com") }

  describe "GET /profile" do
    it "returns 200 for authenticated user and shows profile identity" do
      sign_in user

      get profile_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Avery Stone")
      expect(response.body).to include("avery@example.com")
    end

    it "redirects to login when not authenticated" do
      get profile_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /profile/edit" do
    it "returns 200 for authenticated user" do
      sign_in user

      get edit_profile_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit Profile")
    end
  end

  describe "PATCH /profile" do
    it "updates first_name and last_name" do
      sign_in user

      patch profile_path, params: { user: { first_name: "Jordan", last_name: "Reed" } }

      expect(response).to redirect_to(profile_path)
      expect(user.reload.first_name).to eq("Jordan")
      expect(user.last_name).to eq("Reed")
    end

    it "does not allow role changes" do
      sign_in user

      patch profile_path, params: { user: { first_name: "Jordan", role: "admin" } }

      expect(response).to redirect_to(profile_path)
      expect(user.reload.first_name).to eq("Jordan")
      expect(user.role).to eq("developer")
    end
  end
end
