module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', current_user.email
    end

    private

    def find_verified_user
      token = request.params[:token]
      
      if token
        begin
          payload = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256').first
          user = User.find_by(id: payload['user_id'])
          
          if user&.active?
            return user
          end
        rescue JWT::DecodeError, JWT::ExpiredSignature
          reject_unauthorized_connection
        end
      end
      
      reject_unauthorized_connection
    end
  end
end

