# Base service class for all service objects
# Follows Command Pattern for business logic encapsulation
class ApplicationService
  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs, &block).call
  end

  private

  def success(data = {})
    Result.new(success: true, data: data)
  end

  def failure(errors = [], data = {})
    Result.new(success: false, errors: Array(errors), data: data)
  end

  # Result object for service responses
  class Result
    attr_reader :data, :errors

    def initialize(success:, data: {}, errors: [])
      @success = success
      @data = data
      @errors = errors
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    def error_messages
      errors.join(', ')
    end
  end
end

