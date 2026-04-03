require 'rails_helper'

RSpec.describe 'API V1 Ticket PR Links', type: :request do
  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user: user) }
  let(:headers) { { 'Authorization' => "Bearer #{api_token.token}" } }
  let(:project) { create(:project) }
  let(:ticket) { create(:ticket, project: project) }

  def json_response
    JSON.parse(response.body)
  end

  before do
    create(:project_membership, project: project, user: user)
  end

  describe 'POST /api/v1/tickets/:ticket_id/pr_links' do
    it 'creates a PR link' do
      post "/api/v1/tickets/#{ticket.id}/pr_links", headers: headers, params: {
        pr_link: {
          url: 'https://github.com/example/repo/pull/123',
          title: 'Fix login bug PR',
          status: 'open'
        }
      }

      expect(response).to have_http_status(:created)
      payload = json_response['pr_link']
      expect(payload).to include(
        'url' => 'https://github.com/example/repo/pull/123',
        'title' => 'Fix login bug PR',
        'status' => 'open',
        'user_id' => user.id,
        'ticket_id' => ticket.id
      )
    end

    it 'returns unauthorized without token' do
      post "/api/v1/tickets/#{ticket.id}/pr_links", params: {
        pr_link: { url: 'https://github.com/example/repo/pull/123', title: 'No auth', status: 'open' }
      }

      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to eq('error' => 'Unauthorized')
    end

    it 'returns forbidden when policy denies access' do
      outsider = create(:user)
      outsider_token = create(:api_token, user: outsider)

      post "/api/v1/tickets/#{ticket.id}/pr_links", headers: { 'Authorization' => "Bearer #{outsider_token.token}" }, params: {
        pr_link: { url: 'https://github.com/example/repo/pull/123', title: 'Forbidden', status: 'open' }
      }

      expect(response).to have_http_status(:forbidden)
      expect(json_response).to eq('error' => 'Forbidden')
    end

    it 'returns 422 for invalid params' do
      post "/api/v1/tickets/#{ticket.id}/pr_links", headers: headers, params: {
        pr_link: { url: 'invalid-url', title: '', status: 'open' }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['errors']).to include('Url must be a valid http or https URL', "Title can't be blank")
    end
  end
end
