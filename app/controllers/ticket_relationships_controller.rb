class TicketRelationshipsController < ApplicationController
  before_action :set_ticket

  def create
    authorize @ticket, :show?
    target_ticket = policy_scope(Ticket).find(ticket_relationship_params[:target_ticket_id])

    @ticket_relationship = TicketRelationship.new(
      source_ticket: @ticket,
      target_ticket: target_ticket,
      relationship_type: ticket_relationship_params[:relationship_type]
    )

    if @ticket_relationship.save
      ActivityLog.create!(ticket: @ticket, user: current_user, action: "relationship_added", field_changed: "relationship",
                          new_value: "#{@ticket_relationship.relationship_type}: #{target_ticket.key}")
      redirect_to ticket_path(@ticket), notice: "Related ticket added."
    else
      redirect_to ticket_path(@ticket), alert: @ticket_relationship.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize @ticket, :show?
    ticket_relationship = TicketRelationship.where("source_ticket_id = :id OR target_ticket_id = :id", id: @ticket.id).find(params[:id])
    ticket_relationship.destroy
    redirect_to ticket_path(@ticket), notice: "Related ticket removed."
  end

  private

  def set_ticket
    @ticket = policy_scope(Ticket).find(params[:ticket_id])
  end

  def ticket_relationship_params
    params.require(:ticket_relationship).permit(:target_ticket_id, :relationship_type)
  end
end
