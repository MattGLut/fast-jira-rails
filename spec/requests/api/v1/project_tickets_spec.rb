require 'rails_helper'

RSpec.describe 'API V1 Project Tickets', type: :request do
  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user: user) }
  let(:headers) { { 'Authorization' => "Bearer #{api_token.token}" } }
  let(:project) { create(:project) }

  def json_response
    JSON.parse(response.body)
  end

  before do
    create(:project_membership, project: project, user: user)
  end

  describe 'GET /api/v1/projects/:project_id/tickets' do
    let(:assignee) { create(:user) }
    let!(:matching_ticket) do
      create(:ticket, project: project, title: 'Fix login bug', status: :todo, priority: :high,
                      ticket_type: :bug, assignee: assignee)
    end
    let!(:other_ticket) do
      create(:ticket, project: project, title: 'Implement docs', status: :done, priority: :low,
                      ticket_type: :task)
    end

    before do
      create(:project_membership, project: project, user: assignee)
    end

    it 'returns project tickets with filters applied' do
      get "/api/v1/projects/#{project.id}/tickets",
          params: { status: 'todo', priority: 'high', ticket_type: 'bug', assignee_id: assignee.id, q: 'login' },
          headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['tickets'].size).to eq(1)
      expect(json_response['tickets'].first).to include(
        'id' => matching_ticket.id,
        'key' => matching_ticket.key,
        'status' => 'todo',
        'priority' => 'high',
        'ticket_type' => 'bug',
        'assignee_id' => assignee.id
      )
    end

    it 'returns unauthorized without token' do
      get "/api/v1/projects/#{project.id}/tickets"

      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to eq('error' => 'Unauthorized')
    end

    it 'returns forbidden when policy denies access' do
      outsider = create(:user)
      outsider_token = create(:api_token, user: outsider)

      get "/api/v1/projects/#{project.id}/tickets", headers: { 'Authorization' => "Bearer #{outsider_token.token}" }

      expect(response).to have_http_status(:forbidden)
      expect(json_response).to eq('error' => 'Forbidden')
    end

    it 'returns 422 for invalid filter params' do
      get "/api/v1/projects/#{project.id}/tickets", params: { status: 'not-a-status' }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['errors']).to include('Invalid status')
    end
  end
end
