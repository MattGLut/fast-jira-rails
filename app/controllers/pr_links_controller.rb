class PrLinksController < ApplicationController
  before_action :set_ticket

  def create
    @pr_link = @ticket.pr_links.new(pr_link_params.merge(user: current_user))
    authorize @pr_link

    if @pr_link.save
      ActivityLog.create!(ticket: @ticket, user: current_user, action: "pr_linked", field_changed: "pr_link",
                          new_value: @pr_link.url)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to ticket_path(@ticket), notice: "PR link added." }
      end
    else
      redirect_to ticket_path(@ticket), alert: @pr_link.errors.full_messages.to_sentence
    end
  end

  def destroy
    @pr_link = policy_scope(@ticket.pr_links).find(params[:id])
    authorize @pr_link
    @pr_link.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to ticket_path(@ticket), notice: "PR link removed." }
    end
  end

  private

  def set_ticket
    @ticket = policy_scope(Ticket).find(params[:ticket_id])
    authorize @ticket, :show?
  end

  def pr_link_params
    params.require(:pr_link).permit(:url, :title, :status)
  end
end
