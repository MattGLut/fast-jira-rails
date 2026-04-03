module TokenAuthentication
  extend ActiveSupport::Concern

  included do
    attr_reader :current_api_token
  end

  private

  def authenticate_with_token!
    api_token = token_from_header
    return render_unauthorized unless api_token

    @current_api_token = api_token
    @current_user = api_token.user
    api_token.update_column(:last_used_at, Time.current)
  end

  def current_user
    @current_user
  end

  def token_from_header
    raw_header = request.authorization.to_s
    scheme, token = raw_header.split(' ', 2)
    return if scheme.blank? || token.blank? || !scheme.casecmp('Bearer').zero?

    ApiToken.active.includes(:user).find_by(token: token)
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
