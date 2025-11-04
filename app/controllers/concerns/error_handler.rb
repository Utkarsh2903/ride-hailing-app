# Concern for handling errors consistently across controllers
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    # Custom application errors
    rescue_from ApplicationError, with: :handle_application_error
    
    # Rails/ActiveRecord errors
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    
    # Pundit authorization errors
    rescue_from Pundit::NotAuthorizedError, with: :handle_forbidden
    
    # Parameter errors
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    
    # Catch-all for unexpected errors
    rescue_from StandardError, with: :handle_internal_error
  end

  private

  # Handle custom application errors
  def handle_application_error(error)
    render json: {
      success: false,
      error: {
        code: error.code,
        message: error.message,
        details: error.details
      }
    }, status: error.status
  end

  # Handle unexpected internal errors
  def handle_internal_error(error)
    # Log full error for debugging
    Rails.logger.error("Internal error: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n"))

    # Don't expose internal error details to client
    render json: {
      success: false,
      error: {
        code: 'internal_error',
        message: 'An unexpected error occurred'
      }
    }, status: :internal_server_error
  end

  # Handle record not found (404)
  def handle_not_found(error)
    render json: {
      success: false,
      error: {
        code: 'not_found',
        message: error.message
      }
    }, status: :not_found
  end

  # Handle validation errors
  def handle_record_invalid(error)
    render json: {
      success: false,
      error: {
        code: 'validation_error',
        message: 'Validation failed',
        details: error.record.errors.messages
      }
    }, status: :unprocessable_entity
  end

  # Handle authorization errors
  def handle_forbidden(error)
    render json: {
      success: false,
      error: {
        code: 'forbidden',
        message: error.message
      }
    }, status: :forbidden
  end

  # Handle missing parameters
  def handle_parameter_missing(error)
    render json: {
      success: false,
      error: {
        code: 'parameter_missing',
        message: error.message
      }
    }, status: :bad_request
  end
end
