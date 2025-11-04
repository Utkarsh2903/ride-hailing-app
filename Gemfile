source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.3'
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Authentication & Authorization
gem "bcrypt", "~> 3.1.7"
gem "jwt", "~> 2.7"
gem "pundit", "~> 2.3"

# API & Serialization
gem "jsonapi-serializer", "~> 2.2"
gem "jbuilder"
gem "rack-cors"

# State Machine
gem "aasm", "~> 5.5"

# Background Jobs
gem "sidekiq", "~> 7.2"
gem "sidekiq-cron", "~> 1.12"

# Redis for caching and real-time features
gem "redis", "~> 5.0"
gem "redis-namespace", "~> 1.11"
gem "hiredis-client", "~> 0.22"

# Monitoring & Performance
gem "newrelic_rpm", "~> 9.7"

# Geospatial
gem "rgeo", "~> 3.0"
gem "rgeo-geojson", "~> 2.1"
gem "activerecord-postgis-adapter", "~> 9.0"

# API Documentation
gem "rswag-api"
gem "rswag-ui"

# Validations
gem "validates_timeliness", "~> 7.0.0.beta2"

# Pagination
gem "kaminari", "~> 1.2"

# HTTP Client
gem "faraday", "~> 2.9"
gem "faraday-retry", "~> 2.2"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

group :development, :test do
  # Testing Framework
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
  
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw mswin x64_mingw ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  
  # API Testing
  gem "rswag-specs"
end

group :test do
  gem "shoulda-matchers", "~> 6.1"
  gem "database_cleaner-active_record", "~> 2.1"
  gem "simplecov", require: false
  gem "webmock", "~> 3.20"
  gem "timecop", "~> 0.9"
end

group :development do
  gem "annotate", "~> 3.2"
  gem "bullet", "~> 7.1"
  gem "letter_opener", "~> 1.9"
end
