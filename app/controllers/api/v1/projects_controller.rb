module Api
  module V1
    class ProjectsController < BaseController
      def index
        authorize Project

        projects = policy_scope(Project)
          .left_joins(:tickets)
          .select('projects.*, COUNT(tickets.id) AS tickets_count')
          .group('projects.id')

        render json: {
          projects: projects.map do |project|
            {
              id: project.id,
              name: project.name,
              key: project.key,
              description: project.description,
              ticket_count: project.read_attribute(:tickets_count).to_i
            }
          end
        }
      end

      def show
        project = Project.find(params[:id])
        authorize project

        tickets = project.tickets
        render json: {
          project: {
            id: project.id,
            name: project.name,
            key: project.key,
            description: project.description,
            member_count: project.project_memberships.count,
            ticket_count: tickets.count,
            ticket_stats: Ticket.statuses.keys.index_with { |status| tickets.public_send(status).count }
          }
        }
      end
    end
  end
end
