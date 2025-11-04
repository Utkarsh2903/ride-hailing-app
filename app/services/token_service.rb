# Service for JWT token operations
# Follows Single Responsibility Principle
class TokenService
  ALGORITHM = 'HS256'.freeze
  EXPIRATION = 30.days

  class << self
    def encode(payload)
      payload[:exp] = EXPIRATION.from_now.to_i
      JWT.encode(payload, secret_key, ALGORITHM)
    end

    def decode(token)
      JWT.decode(token, secret_key, true, algorithm: ALGORITHM).first
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

    def generate_for_user(user)
      encode(
        user_id: user.id,
        email: user.email,
        role: user.role
      )
    end

    private

    def secret_key
      Rails.application.credentials.secret_key_base
    end
  end
end

