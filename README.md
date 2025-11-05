# Ride Hailing App

A multi-tenant ride-hailing platform built with Ruby on Rails 7.1.3.

## Tech Stack

- **Ruby** 3.4.7
- **Rails** 7.1.3 (API-only)
- **PostgreSQL** with PostGIS
- **Redis** (caching, geospatial, Sidekiq)
- **Sidekiq** (background jobs)

## Features

- Multi-tenant architecture
- Real-time driver location tracking (Redis geospatial)
- Driver-rider matching (<1s p95)
- Trip lifecycle management
- Payment processing (stubbed, ready for PSP integration)
- Notifications (multi-channel)
- JWT authentication
- Pundit authorization

## Railway Deployment

Already deployed! Your app is live at: `https://your-app.railway.app`

### One-Time Setup

Run these in Railway Dashboard (via "Run Command" or Shell):

```bash
# Enable PostGIS
rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')"

# Create test tenant and user
rails runner "
  tenant = Tenant.find_or_create_by!(subdomain: 'test') do |t|
    t.name = 'Test Company'
    t.status = 'active'
  end
  
  User.find_or_create_by!(email: 'admin@test.com') do |u|
    u.tenant = tenant
    u.password = 'password123'
    u.role = 'super_admin'
    u.status = 'active'
  end
"
```

### Environment Variables (Railway)

Set these in Railway Dashboard → Variables:

```
RAILS_MASTER_KEY=<from config/master.key>
SECRET_KEY_BASE=<generate with: openssl rand -hex 64>
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
DATABASE_URL=<auto-set by PostgreSQL service>
REDIS_URL=<auto-set by Redis service>
```

## API Documentation

- Swagger UI: `https://your-app.railway.app/api-docs`
- Health Check: `https://your-app.railway.app/health`

## Core Endpoints

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/rides
GET    /api/v1/rides/:id
POST   /api/v1/drivers/:id/location
POST   /api/v1/drivers/:id/accept
POST   /api/v1/trips/:id/end
POST   /api/v1/payments
```

## Local Development

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Start server
rails server

# Start Sidekiq (separate terminal)
bundle exec sidekiq
```

## Testing

```bash
rspec
```

## License

Proprietary
