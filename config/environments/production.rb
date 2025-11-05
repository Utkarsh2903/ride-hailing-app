require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Production settings
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  
  # Cache configuration
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  
  # Logging
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  
  # Deprecations
  config.active_support.report_deprecations = false
  
  # Mailer (disabled for API-only)
  config.action_mailer.perform_caching = false
  
  # Internationalization
  config.i18n.fallbacks = true
  
  # Database
  config.active_record.dump_schema_after_migration = false
  
  # API-only configuration
  config.api_only = true
end

