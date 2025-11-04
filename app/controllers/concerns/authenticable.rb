# Concern for authentication logic
module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    attr_reader :current_user
  end

  private

  def authenticate_user!
    token = extract_token
    raise AuthenticationError.new('Token not provided') unless token

    @current_user = authenticate_with_token(token)
    raise AuthenticationError.new('Invalid or expired token') unless @current_user
    raise AuthenticationError.new('User account is inactive') unless @current_user.active?
  end

  def extract_token
    request.headers['Authorization']&.split(' ')&.last
  end

  def authenticate_with_token(token)
    payload = TokenService.decode(token)
    return nil unless payload
    
    User.find_by(id: payload['user_id'])
  end

  def current_rider
    @current_rider ||= current_user&.rider
  end

  def current_driver
    @current_driver ||= current_user&.driver
  end
end
