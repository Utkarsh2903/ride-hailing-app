# Ride Hailing App

A production-ready, multi-tenant, multi-region ride-hailing platform built with Ruby on Rails.

## 🚀 Features

- **Multi-tenant**: Fully isolated tenant data with automatic scoping
- **Multi-region**: Designed for region-specific operations
- **Real-time Location**: Driver location tracking (1-2 updates/sec)
- **Smart Matching**: Sub-second driver-rider matching with Redis
- **Trip Management**: Complete trip lifecycle with fare calculation
- **Payments**: PSP integration structure (Stripe/PayPal ready)
- **Notifications**: Multi-channel notification system
- **Scalable**: Redis caching, Sidekiq workers, stateless APIs

## 📋 Tech Stack

- **Framework**: Ruby on Rails 7.1.3 (API-only, Production mode)
- **Database**: PostgreSQL with PostGIS
- **Cache/Queue**: Redis, Sidekiq
- **Auth**: JWT with Pundit authorization
- **Geospatial**: RGeo, PostGIS, Redis GEOADD/GEORADIUS

## 🔧 Local Setup (Production Mode)

### Prerequisites
- Ruby 3.4.7
- PostgreSQL with PostGIS
- Redis

### Quick Start

```bash
# 1. Install dependencies
bundle install --without development test

# 2. Setup environment (creates .env file)
./bin/setup_production

# 3. Start server
RAILS_ENV=production bundle exec rails server

# 4. Start worker (in another terminal)
RAILS_ENV=production bundle exec sidekiq -C config/sidekiq.yml
```

### Manual Setup

```bash
# 1. Create .env file with required variables
cp .env.example .env
# Edit .env with your credentials

# 2. Setup database
RAILS_ENV=production bundle exec rails db:create db:migrate

# 3. Create initial tenant and user
RAILS_ENV=production bundle exec rails runner "
tenant = Tenant.create!(subdomain: 'test', name: 'Test Company', status: 'active', default_payment_provider: 'stripe')
User.create!(tenant: tenant, email: 'admin@test.com', password: 'password123', role: 'super_admin', status: 'active')
"
```

## 🚀 Deployment (Railway)

### Automatic Deployment

1. Connect your GitHub repo to Railway
2. Add PostgreSQL and Redis services
3. Set environment variables (see below)
4. Deploy! (migrations run automatically)

### Required Environment Variables

```bash
# Auto-set by Railway
DATABASE_URL=postgresql://...
REDIS_URL=redis://...

# Required
SECRET_KEY_BASE=<generate with: rails secret>
RAILS_MASTER_KEY=<from config/master.key>

# Optional
CORS_ORIGINS=*
PORT=8080
```

## 📡 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register user
- `POST /api/v1/auth/login` - Login
- `GET /api/v1/auth/me` - Current user

### Rides
- `POST /api/v1/rides` - Create ride request
- `GET /api/v1/rides/:id` - Get ride status
- `POST /api/v1/rides/:id/cancel` - Cancel ride
- `GET /api/v1/rides/:id/track` - Track ride

### Drivers
- `POST /api/v1/drivers/:id/location` - Update location
- `POST /api/v1/drivers/:id/accept` - Accept ride
- `POST /api/v1/drivers/:id/decline` - Decline ride
- `POST /api/v1/drivers/:id/start_trip` - Start trip

### Trips
- `GET /api/v1/trips/:id` - Get trip details
- `POST /api/v1/trips/:id/end` - End trip

### Payments
- `POST /api/v1/payments` - Create payment
- `POST /api/v1/payments/:id/retry` - Retry payment
- `POST /api/v1/payments/:id/refund` - Refund payment

**All requests require:**
- `X-Tenant-ID` header (e.g., "test")
- `Authorization: Bearer <token>` (except login/register)

## 🏗️ Architecture Highlights

- **Stateless APIs**: No server-side sessions, horizontal scaling ready
- **Tenant Isolation**: Automatic scoping via `TenantScoped` concern
- **Redis Geospatial**: Fast driver lookups within radius
- **AASM State Machines**: Clean state transitions for rides/trips/payments
- **Idempotency**: Prevents duplicate requests via `Idempotency-Key`
- **Background Jobs**: Async matching, payments, notifications

## 📊 Performance Targets

- Driver-rider matching: **<1s p95**
- Location updates: **1-2 per second per driver**
- Concurrent drivers: **~100k**
- Ride requests: **~10k/min**
- Location updates: **~200k/sec**

## 🔐 Security

- JWT authentication with expiry
- Pundit authorization policies
- SQL injection protection (parameterized queries)
- CORS configuration
- Tenant isolation at database level

## 📝 Environment

**Production-only**: This application runs exclusively in production mode for consistency and performance.

## 📄 License

Proprietary
