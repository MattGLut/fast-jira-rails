require 'rails_helper'

RSpec.describe 'API V1 Tickets', type: :request do
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

  describe 'GET /api/v1/tickets/:id' do
    let(:ticket) { create(:ticket, :assigned, project: project, reporter: user) }

    before do
      create(:project_membership, project: project, user: ticket.assignee)
      create(:comment, ticket: ticket, user: user)
      create(:pr_link, ticket: ticket, user: user)
      ticket.labels << create(:label, project: project)
    end

    it 'returns ticket with associations' do
      get "/api/v1/tickets/#{ticket.id}", headers: headers

      expect(response).to have_http_status(:ok)
      payload = json_response['ticket']
      expect(payload).to include(
        'id' => ticket.id,
        'key' => ticket.key,
        'title' => ticket.title,
        'status' => ticket.status,
        'priority' => ticket.priority,
        'ticket_type' => ticket.ticket_type
      )
      expect(payload['reporter']).to include('id' => user.id, 'email' => user.email)
      expect(payload['assignee']).to include('id' => ticket.assignee.id)
      expect(payload['project']).to include('id' => project.id, 'key' => project.key)
      expect(payload['comments'].size).to eq(1)
      expect(payload['pr_links'].size).to eq(1)
      expect(payload['labels'].size).to eq(1)
    end

    it 'returns unauthorized without token' do
      get "/api/v1/tickets/#{ticket.id}"

      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to eq('error' => 'Unauthorized')
    end

    it 'returns forbidden when policy denies access' do
      outsider = create(:user)
      outsider_token = create(:api_token, user: outsider)

      get "/api/v1/tickets/#{ticket.id}", headers: { 'Authorization' => "Bearer #{outsider_token.token}" }

      expect(response).to have_http_status(:forbidden)
      expect(json_response).to eq('error' => 'Forbidden')
    end
  end

  describe 'POST /api/v1/tickets' do
    it 'creates a ticket with current_user as reporter' do
      post '/api/v1/tickets', headers: headers, params: {
        ticket: {
          project_id: project.id,
          title: 'Fix login bug',
          description: 'Investigate auth flow',
          priority: 'high',
          ticket_type: 'bug',
          story_points: 5,
          due_date: Date.current.to_s
        }
      }

      expect(response).to have_http_status(:created)
      payload = json_response['ticket']
      expect(payload).to include(
        'title' => 'Fix login bug',
        'priority' => 'high',
        'ticket_type' => 'bug',
        'story_points' => 5
      )
      expect(payload['reporter']).to include('id' => user.id)
      expect(Ticket.last.reporter_id).to eq(user.id)
    end

    it 'returns 422 for invalid params' do
      post '/api/v1/tickets', headers: headers, params: {
        ticket: {
          project_id: project.id,
          title: '',
          priority: 'high',
          ticket_type: 'bug'
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['errors']).to include("Title can't be blank")
    end
  end

  describe 'PATCH /api/v1/tickets/:id/assign' do
    let(:manager) { create(:user) }
    let(:manager_token) { create(:api_token, user: manager) }
    let(:ticket) { create(:ticket, project: project) }

    before do
      create(:project_membership, :manager, project: project, user: manager)
    end

    it 'self-assigns and creates an activity log' do
      patch "/api/v1/tickets/#{ticket.id}/assign", headers: { 'Authorization' => "Bearer #{manager_token.token}" }

      expect(response).to have_http_status(:ok)
      expect(ticket.reload.assignee).to eq(manager)
      log = ticket.activity_logs.order(:created_at).last
      expect(log).to have_attributes(
        action: 'assignee_changed',
        field_changed: 'assignee_id',
        new_value: manager.id.to_s,
        user_id: manager.id
      )
    end

    it 'returns forbidden when policy denies access' do
      patch "/api/v1/tickets/#{ticket.id}/assign", headers: headers

      expect(response).to have_http_status(:forbidden)
      expect(json_response).to eq('error' => 'Forbidden')
    end
  end

  describe 'PATCH /api/v1/tickets/:id/transition' do
    let(:ticket) { create(:ticket, project: project, assignee: user, status: :todo) }

    it 'transitions status and creates activity log' do
      patch "/api/v1/tickets/#{ticket.id}/transition", headers: headers, params: { status: 'in_progress' }

      expect(response).to have_http_status(:ok)
      expect(ticket.reload.status).to eq('in_progress')
      log = ticket.activity_logs.order(:created_at).last
      expect(log).to have_attributes(
        action: 'status_changed',
        field_changed: 'status',
        old_value: 'todo',
        new_value: 'in_progress',
        user_id: user.id
      )
    end

    it 'returns 422 for invalid status' do
      patch "/api/v1/tickets/#{ticket.id}/transition", headers: headers, params: { status: 'invalid' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['errors']).to include('Invalid status')
    end
  end
end
