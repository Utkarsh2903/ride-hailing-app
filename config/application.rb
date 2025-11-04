require_relative "boot"

require "rails"
# Pick the frameworks you want (API-only app):
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"  # Not needed for API-only
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"  # Not needed for API-only
# require "action_text/engine"      # Not needed for API-only
# require "action_view/railtie"     # Not needed for API-only
# require "action_cable/engine"     # Not needed for API-only
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RideHailingApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    
    # ActiveJob configuration
    config.active_job.queue_adapter = :sidekiq
  end
end
