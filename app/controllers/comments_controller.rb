class CommentsController < ApplicationController
  before_action :set_ticket

  def create
    @comment = @ticket.comments.new(comment_params.merge(user: current_user))
    authorize @comment

    if @comment.save
      ActivityLog.create!(ticket: @ticket, user: current_user, action: "commented", field_changed: "comment")
      NotificationService.comment_added(@comment, current_user)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to ticket_path(@ticket), notice: "Comment added." }
      end
    else
      redirect_to ticket_path(@ticket), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @comment = policy_scope(@ticket.comments).find(params[:id])
    authorize @comment

    @comment.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to ticket_path(@ticket), notice: "Comment deleted." }
    end
  end

  private

  def set_ticket
    @ticket = policy_scope(Ticket).find(params[:ticket_id])
    authorize @ticket, :show?
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
