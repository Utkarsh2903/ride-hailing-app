module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [:login, :register]

      # POST /api/v1/auth/register
      def register
        # Validate request parameters
        validator = UserRegisterParams.from_params(user_params)
        unless validator.valid?
          return render_error('Registration failed', details: validator.errors.messages, status: :unprocessable_entity)
        end

        user = User.new(validator.to_h)
        
        if user.save
          token = TokenService.generate_for_user(user)
          render_success({
            user: UserSerializer.new(user).serializable_hash[:data][:attributes],
            token: token
          }, status: :created)
        else
          render_error('Registration failed', details: user.errors.messages, status: :unprocessable_entity)
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = TokenService.generate_for_user(user)
          render_success({
            user: UserSerializer.new(user).serializable_hash[:data][:attributes],
            token: token
          })
        else
          render_error('Invalid email or password', status: :unauthorized)
        end
      end

      # GET /api/v1/auth/me
      def me
        render_success(user: UserSerializer.new(current_user).serializable_hash[:data][:attributes])
      end

      # POST /api/v1/auth/logout
      def logout
        # In a production app, you'd invalidate the token
        # For JWT, you might add it to a blacklist in Redis
        render_success(message: 'Logged out successfully')
      end

      private

      def user_params
        params.require(:user).permit(
          :email,
          :phone,
          :password,
          :password_confirmation,
          :first_name,
          :last_name,
          :role
        )
      end
    end
  end
end

