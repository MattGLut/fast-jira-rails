module Api
  module V1
    module Tickets
      class PrLinksController < BaseController
        def create
          ticket = Ticket.find(params[:ticket_id])

          if pr_link_params[:status].present? && !PrLink.statuses.key?(pr_link_params[:status])
            return render json: { errors: ['Invalid status'] }, status: :unprocessable_entity
          end

          pr_link = ticket.pr_links.new(pr_link_params.merge(user: current_user))
          authorize pr_link

          if pr_link.save
            render json: {
              pr_link: {
                id: pr_link.id,
                url: pr_link.url,
                title: pr_link.title,
                status: pr_link.status,
                user_id: pr_link.user_id,
                ticket_id: pr_link.ticket_id,
                created_at: pr_link.created_at,
                updated_at: pr_link.updated_at
              }
            }, status: :created
          else
            render json: { errors: pr_link.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def pr_link_params
          params.require(:pr_link).permit(:url, :title, :status)
        end
      end
    end
  end
end
