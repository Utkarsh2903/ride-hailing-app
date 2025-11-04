# Base class for all custom application errors
class ApplicationError < StandardError
  attr_reader :status, :code, :details

  def initialize(message = nil, status: :unprocessable_entity, code: nil, details: {})
    super(message)
    @status = status
    @code = code || self.class.name.demodulize.underscore
    @details = details
  end
end

# Business Logic Errors
class BusinessLogicError < ApplicationError
  def initialize(message, details: {})
    super(message, status: :unprocessable_entity, details: details)
  end
end

class ValidationError < ApplicationError
  def initialize(message, details: {})
    super(message, status: :unprocessable_entity, code: 'validation_error', details: details)
  end
end

class AuthorizationError < ApplicationError
  def initialize(message = 'Not authorized')
    super(message, status: :forbidden, code: 'forbidden')
  end
end

class AuthenticationError < ApplicationError
  def initialize(message = 'Unauthorized')
    super(message, status: :unauthorized, code: 'unauthorized')
  end
end

class NotFoundError < ApplicationError
  def initialize(message = 'Resource not found')
    super(message, status: :not_found, code: 'not_found')
  end
end

class RateLimitError < ApplicationError
  def initialize(message = 'Rate limit exceeded')
    super(message, status: :too_many_requests, code: 'rate_limit_exceeded')
  end
end

