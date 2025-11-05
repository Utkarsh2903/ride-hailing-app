web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
release: bundle exec rails db:prepare && bundle exec rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis'); ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"')"

