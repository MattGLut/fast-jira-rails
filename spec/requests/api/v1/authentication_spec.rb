require 'rails_helper'

RSpec.describe 'API V1 Token Authentication', type: :request do
  before do
    stub_const('Api::V1::AuthenticationTestController', Class.new(Api::V1::BaseController) do
      skip_after_action :verify_authorized, only: :index

      def index
        render json: { user_id: current_user.id }
      end
    end)

    Rails.application.routes.draw do
      namespace :api do
        namespace :v1 do
          get 'authentication_test', to: 'authentication_test#index'
        end
      end
    end
  end

  after do
    Rails.application.reload_routes!
  end

  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user: user) }
  let(:path) { '/api/v1/authentication_test' }

  it 'authenticates successfully with a valid bearer token' do
    get path, headers: { 'Authorization' => "Bearer #{api_token.token}" }

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq('user_id' => user.id)
    expect(api_token.reload.last_used_at).to be_present
  end

  it 'returns unauthorized when token is inactive' do
    api_token.update!(active: false)

    get path, headers: { 'Authorization' => "Bearer #{api_token.token}" }

    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body)).to eq('error' => 'Unauthorized')
  end

  it 'returns unauthorized when token is missing' do
    get path

    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body)).to eq('error' => 'Unauthorized')
  end

  it 'returns unauthorized when token is invalid' do
    get path, headers: { 'Authorization' => 'Bearer invalid-token' }

    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body)).to eq('error' => 'Unauthorized')
  end
end
