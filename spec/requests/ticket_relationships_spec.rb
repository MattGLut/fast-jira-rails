require "rails_helper"

RSpec.describe "TicketRelationships", type: :request do
  let(:project) { create(:project) }
  let(:member) { create(:user) }
  let(:outsider) { create(:user) }
  let(:source_ticket) { create(:ticket, project: project, reporter: member) }
  let(:target_ticket) { create(:ticket, project: project, reporter: member) }

  before do
    create(:project_membership, project: project, user: member)
  end

  describe "POST /tickets/:id/ticket_relationships" do
    it "creates relationship" do
      sign_in member

      expect do
        post ticket_ticket_relationships_path(source_ticket), params: {
          ticket_relationship: { target_ticket_id: target_ticket.id, relationship_type: "blocks" }
        }
      end.to change(TicketRelationship, :count).by(1)

      relationship = TicketRelationship.last
      expect(relationship.source_ticket).to eq(source_ticket)
      expect(relationship.target_ticket).to eq(target_ticket)
      expect(response).to redirect_to(ticket_path(source_ticket))
    end

    it "returns validation errors for invalid params" do
      sign_in member

      expect do
        post ticket_ticket_relationships_path(source_ticket), params: {
          ticket_relationship: { target_ticket_id: source_ticket.id, relationship_type: "blocks" }
        }
      end.not_to change(TicketRelationship, :count)

      expect(response).to redirect_to(ticket_path(source_ticket))
      expect(flash[:alert]).to be_present
    end

    it "redirects unauthenticated user" do
      post ticket_ticket_relationships_path(source_ticket), params: {
        ticket_relationship: { target_ticket_id: target_ticket.id, relationship_type: "blocks" }
      }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "blocks non-member access" do
      sign_in outsider

      post ticket_ticket_relationships_path(source_ticket), params: {
        ticket_relationship: { target_ticket_id: target_ticket.id, relationship_type: "blocks" }
      }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /tickets/:id/ticket_relationships/:id" do
    let!(:relationship) { create(:ticket_relationship, source_ticket: source_ticket, target_ticket: target_ticket) }

    it "destroys relationship" do
      sign_in member

      expect do
        delete ticket_ticket_relationship_path(source_ticket, relationship)
      end.to change(TicketRelationship, :count).by(-1)

      expect(response).to redirect_to(ticket_path(source_ticket))
    end
  end
end
