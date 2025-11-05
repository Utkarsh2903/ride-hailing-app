# Ride Hailing App

A production-ready, multi-tenant ride-hailing platform built with Ruby on Rails 7.1.3.

## Tech Stack

- **Ruby** 3.4.7
- **Rails** 7.1.3 (API-only)
- **PostgreSQL** with PostGIS
- **Redis** (caching, geospatial, Sidekiq)
- **Sidekiq** (background jobs)
- **New Relic** (monitoring)

## Features

- ✅ Multi-tenant architecture
- ✅ Real-time driver location tracking (Redis geospatial)
- ✅ Driver-rider matching (<1s p95)
- ✅ Trip lifecycle management
- ✅ Payment processing (ready for PSP integration)
- ✅ Multi-channel notifications
- ✅ JWT authentication
- ✅ Pundit authorization

## Production Deployment (Railway)

See `DEPLOYMENT.md` for detailed instructions.

### Quick Deploy

1. Push to GitHub
2. Connect to Railway
3. Add PostgreSQL and Redis services
4. Set environment variables (see below)
5. Deploy! (automatic DB setup, migrations, PostGIS)

### Required Environment Variables

```
RAILS_MASTER_KEY=<from config/master.key>
SECRET_KEY_BASE=<generate with: openssl rand -hex 64>
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
DATABASE_URL=<auto-set>
REDIS_URL=<auto-set>
```

## API Documentation

- Swagger UI: `https://your-app.railway.app/api-docs`
- Health Check: `https://your-app.railway.app/health`

## Core Endpoints

```
POST   /api/v1/auth/register      # User registration
POST   /api/v1/auth/login         # Authentication
POST   /api/v1/rides              # Create ride request
GET    /api/v1/rides/:id          # Get ride details
POST   /api/v1/drivers/:id/location  # Update driver location
POST   /api/v1/drivers/:id/accept     # Accept ride
POST   /api/v1/trips/:id/end      # Complete trip
POST   /api/v1/payments           # Process payment
```

## Architecture

- **API-only**: No views, frontend, or assets
- **Multi-tenant**: Complete data isolation
- **Stateless**: JWT-based authentication
- **Scalable**: Redis caching, background jobs
- **Production-ready**: No dev/test dependencies

## License

Proprietary
