module Api
  module V1
    class TicketsController < BaseController
      before_action :set_ticket, only: %i[show assign transition]

      def show
        authorize @ticket

        render json: {
          ticket: ticket_payload(@ticket).merge(
            comments: @ticket.comments.includes(:user).map do |comment|
              {
                id: comment.id,
                body: comment.body,
                agent_authored: comment.agent_authored,
                user: user_payload(comment.user),
                created_at: comment.created_at,
                updated_at: comment.updated_at
              }
            end,
            pr_links: @ticket.pr_links.includes(:user).map do |pr_link|
              {
                id: pr_link.id,
                url: pr_link.url,
                title: pr_link.title,
                status: pr_link.status,
                user: user_payload(pr_link.user),
                created_at: pr_link.created_at,
                updated_at: pr_link.updated_at
              }
            end,
            labels: @ticket.labels.map do |label|
              {
                id: label.id,
                name: label.name,
                color: label.color
              }
            end
          )
        }
      end

      def create
        ticket = Ticket.new(ticket_params.merge(reporter: current_user))
        authorize ticket

        if ticket.save
          render json: { ticket: ticket_payload(ticket) }, status: :created
        else
          render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def assign
        authorize @ticket, :assign?

        previous_assignee_id = @ticket.assignee_id

        ActiveRecord::Base.transaction do
          @ticket.update!(assignee: current_user)
          @ticket.activity_logs.create!(
            action: 'assignee_changed',
            field_changed: 'assignee_id',
            old_value: previous_assignee_id&.to_s,
            new_value: current_user.id.to_s,
            user: current_user
          )
          NotificationService.ticket_assigned(@ticket, current_user)
        end

        render json: { ticket: ticket_payload(@ticket.reload) }
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end

      def transition
        authorize @ticket, :transition?

        new_status = params[:status].to_s
        unless Ticket.statuses.key?(new_status)
          return render json: { errors: ['Invalid status'] }, status: :unprocessable_entity
        end

        old_status = @ticket.status

        ActiveRecord::Base.transaction do
          @ticket.update!(status: new_status)
          @ticket.activity_logs.create!(
            action: 'status_changed',
            field_changed: 'status',
            old_value: old_status,
            new_value: new_status,
            user: current_user
          )
          NotificationService.status_changed(@ticket, current_user, old_status, new_status)
        end

        render json: { ticket: ticket_payload(@ticket.reload) }
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end

      private

      def set_ticket
        @ticket = Ticket
          .includes(:project, :reporter, :assignee, :labels, comments: :user, pr_links: :user)
          .find(params[:id])
      end

      def ticket_params
        params.require(:ticket).permit(:project_id, :title, :description, :priority, :ticket_type, :story_points, :due_date)
      end

      def ticket_payload(ticket)
        {
          id: ticket.id,
          key: ticket.key,
          title: ticket.title,
          description: ticket.description,
          status: ticket.status,
          priority: ticket.priority,
          ticket_type: ticket.ticket_type,
          story_points: ticket.story_points,
          due_date: ticket.due_date,
          ticket_number: ticket.ticket_number,
          reporter: user_payload(ticket.reporter),
          assignee: ticket.assignee ? user_payload(ticket.assignee) : nil,
          project: {
            id: ticket.project.id,
            name: ticket.project.name,
            key: ticket.project.key
          },
          created_at: ticket.created_at,
          updated_at: ticket.updated_at
        }
      end

      def user_payload(user)
        {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name
        }
      end
    end
  end
end
