require 'rails_helper'

RSpec.describe 'API V1 Projects', type: :request do
  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user: user) }
  let(:headers) { { 'Authorization' => "Bearer #{api_token.token}" } }

  def json_response
    JSON.parse(response.body)
  end

  describe 'GET /api/v1/projects' do
    let!(:visible_project) { create(:project) }
    let!(:hidden_project) { create(:project) }

    before do
      create(:project_membership, project: visible_project, user: user)
      create(:ticket, project: visible_project)
      create(:ticket, project: visible_project)
      create(:ticket, project: hidden_project)
    end

    it 'returns projects in policy scope' do
      get '/api/v1/projects', headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['projects'].size).to eq(1)
      expect(json_response['projects'].first).to include(
        'id' => visible_project.id,
        'name' => visible_project.name,
        'key' => visible_project.key,
        'ticket_count' => 2
      )
    end

    it 'returns unauthorized without token' do
      get '/api/v1/projects'

      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to eq('error' => 'Unauthorized')
    end
  end

  describe 'GET /api/v1/projects/:id' do
    let(:project) { create(:project) }

    before do
      create(:project_membership, project: project, user: user)
      create(:project_membership, :manager, project: project)
      create(:ticket, project: project, status: :todo)
      create(:ticket, project: project, status: :in_progress)
    end

    it 'returns project details with stats' do
      get "/api/v1/projects/#{project.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['project']).to include(
        'id' => project.id,
        'name' => project.name,
        'member_count' => 2,
        'ticket_count' => 2
      )
      expect(json_response['project']['ticket_stats']).to include(
        'todo' => 1,
        'in_progress' => 1,
        'done' => 0
      )
    end

    it 'returns forbidden when policy denies access' do
      outsider = create(:user)
      outsider_token = create(:api_token, user: outsider)

      get "/api/v1/projects/#{project.id}", headers: { 'Authorization' => "Bearer #{outsider_token.token}" }

      expect(response).to have_http_status(:forbidden)
      expect(json_response).to eq('error' => 'Forbidden')
    end
  end
end
