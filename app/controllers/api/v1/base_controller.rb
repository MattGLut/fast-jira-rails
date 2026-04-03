module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization
      include TokenAuthentication

      before_action :authenticate_with_token!

      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      private

      def pundit_user
        current_user
      end

      def render_forbidden
        render json: { error: 'Forbidden' }, status: :forbidden
      end

      def render_not_found
        render json: { error: 'Not Found' }, status: :not_found
      end
    end
  end
end
