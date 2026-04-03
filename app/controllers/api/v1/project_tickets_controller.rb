module Api
  module V1
    class ProjectTicketsController < BaseController
      def index
        project = Project.find(params[:project_id])
        authorize project, :show?

        tickets = policy_scope(project.tickets)
          .includes(:reporter, :assignee)
          .order(created_at: :desc)

        tickets = apply_enum_filter(tickets, :status, params[:status])
        return if performed?

        tickets = apply_enum_filter(tickets, :priority, params[:priority])
        return if performed?

        tickets = apply_enum_filter(tickets, :ticket_type, params[:ticket_type])
        return if performed?

        tickets = tickets.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
        tickets = apply_search(tickets, params[:q])

        render json: {
          tickets: tickets.map do |ticket|
            {
              id: ticket.id,
              key: ticket.key,
              title: ticket.title,
              status: ticket.status,
              priority: ticket.priority,
              ticket_type: ticket.ticket_type,
              assignee_id: ticket.assignee_id,
              reporter_id: ticket.reporter_id,
              created_at: ticket.created_at,
              updated_at: ticket.updated_at
            }
          end
        }
      end

      private

      def apply_enum_filter(scope, field, raw_value)
        return scope if raw_value.blank?

        mapping = Ticket.public_send(field.to_s.pluralize)
        unless mapping.key?(raw_value)
          render json: { errors: ["Invalid #{field}"] }, status: :unprocessable_entity
          return scope
        end

        scope.where(field => raw_value)
      end

      def apply_search(scope, query)
        return scope if query.blank?

        sanitized = ActiveRecord::Base.sanitize_sql_like(query)
        scope.where('LOWER(tickets.title) LIKE :term OR LOWER(tickets.description) LIKE :term',
                    term: "%#{sanitized.downcase}%")
      end
    end
  end
end
