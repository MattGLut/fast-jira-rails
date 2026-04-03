module Api
  module V1
    module Tickets
      class CommentsController < BaseController
        def create
          ticket = Ticket.find(params[:ticket_id])
          comment = ticket.comments.new(comment_params.merge(user: current_user, agent_authored: true))
          authorize comment

          if comment.save
            NotificationService.comment_added(comment, current_user)
            render json: {
              comment: {
                id: comment.id,
                body: comment.body,
                agent_authored: comment.agent_authored,
                user_id: comment.user_id,
                ticket_id: comment.ticket_id,
                created_at: comment.created_at,
                updated_at: comment.updated_at
              }
            }, status: :created
          else
            render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def comment_params
          params.require(:comment).permit(:body)
        end
      end
    end
  end
end
