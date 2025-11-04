# Configure Redis connection
require 'redis'

REDIS_URL = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

# Configure Redis for Rails cache
Rails.application.config.cache_store = :redis_cache_store, {
  url: REDIS_URL,
  namespace: 'ride_hailing',
  expires_in: 90.minutes,
  pool_size: ENV.fetch('RAILS_MAX_THREADS', 5).to_i,
  pool_timeout: 5,
  reconnect_attempts: 3,
  error_handler: -> (method:, returning:, exception:) {
    Rails.logger.error("Redis error: #{method} - #{exception.message}")
  }
}

# ActionCable disabled for API-only app
# Rails.application.config.action_cable.cable = { ... }

# Global Redis connection for custom operations
$redis = Redis.new(
  url: REDIS_URL,
  timeout: 5,
  reconnect_attempts: 3
)

