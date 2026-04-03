require 'rails_helper'

RSpec.describe 'API V1 Ticket Comments', type: :request do
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

  describe 'POST /api/v1/tickets/:ticket_id/comments' do
    it 'creates a comment as agent-authored' do
      post "/api/v1/tickets/#{ticket.id}/comments", headers: headers, params: { comment: { body: 'Investigating this now' } }

      expect(response).to have_http_status(:created)
      payload = json_response['comment']
      expect(payload).to include(
        'body' => 'Investigating this now',
        'agent_authored' => true,
        'user_id' => user.id,
        'ticket_id' => ticket.id
      )
      expect(Comment.last.agent_authored).to be(true)
    end

    it 'returns unauthorized without token' do
      post "/api/v1/tickets/#{ticket.id}/comments", params: { comment: { body: 'No auth' } }

      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to eq('error' => 'Unauthorized')
    end

    it 'returns forbidden when policy denies access' do
      outsider = create(:user)
      outsider_token = create(:api_token, user: outsider)

      post "/api/v1/tickets/#{ticket.id}/comments",
           headers: { 'Authorization' => "Bearer #{outsider_token.token}" },
           params: { comment: { body: 'Cannot comment here' } }

      expect(response).to have_http_status(:forbidden)
      expect(json_response).to eq('error' => 'Forbidden')
    end

    it 'returns 422 for invalid params' do
      post "/api/v1/tickets/#{ticket.id}/comments", headers: headers, params: { comment: { body: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['errors']).to include("Body can't be blank")
    end
  end
end
