# Ride Hailing Platform

A scalable, multi-tenant, multi-region ride-hailing platform built with Ruby on Rails.

## 🚀 Features

- **Multi-Tenancy**: Isolate data by tenant for different markets/regions
- **Multi-Region**: Deploy across multiple geographic regions
- **Real-time Location Tracking**: Driver locations updated 1-2 times/second
- **Driver-Rider Matching**: Sub-second matching with intelligent ranking
- **Trip Management**: Complete lifecycle from request to completion
- **Payments**: Integration with external payment service providers
- **Notifications**: Multi-channel (WebSocket, Push, SMS, Email)
- **Surge Pricing**: Dynamic pricing based on supply/demand
- **State Machines**: Clean state transitions for rides, trips, and payments

## 📋 Requirements

- Ruby 3.2+
- Rails 7.1.3
- PostgreSQL 14+ with PostGIS extension
- Redis 7+
- Sidekiq 7+

## 🛠️ Installation

### 1. Clone Repository

```bash
git clone <repository-url>
cd ride-hailing-app
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Setup Database

```bash
# Create databases
rails db:create

# Run migrations
rails db:migrate

# Seed initial data (optional)
rails db:seed
```

### 4. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your credentials
```

Required environment variables:
```
DATABASE_URL=postgresql://localhost/ridehailing_development
REDIS_URL=redis://localhost:6379/0
SECRET_KEY_BASE=<generate with: rails secret>
```

### 5. Start Services

```bash
# Terminal 1: Rails server
rails server

# Terminal 2: Sidekiq (background jobs)
bundle exec sidekiq

# Terminal 3: Redis (if not running as service)
redis-server
```

## 📖 API Documentation

See [API_REFERENCE.md](API_REFERENCE.md) for complete API documentation.

### Quick Start

```bash
# Register a rider
POST /api/v1/auth/register
{
  "user": {
    "email": "rider@example.com",
    "password": "password",
    "role": "rider"
  }
}

# Create a ride
POST /api/v1/rides
Headers: Authorization: Bearer <jwt_token>
{
  "ride": {
    "pickup_latitude": 37.7749,
    "pickup_longitude": -122.4194,
    "dropoff_latitude": 37.7849,
    "dropoff_longitude": -122.4094,
    "tier": "standard"
  }
}
```

## 🏗️ Architecture

### Application Layers

```
Controllers (API endpoints, strong parameters)
    ↓
Services (Complex business logic)
    ↓
Models (Data validation, associations, scopes)
    ↓
Database (PostgreSQL + PostGIS)
```

### Key Components

- **Models**: User, Driver, Rider, Ride, Trip, Payment
- **Services**: RideCreation, DriverMatching, FareCalculation, Notifications
- **Jobs**: Background processing for matching, payments, location persistence
- **Channels**: WebSocket connections for real-time updates

## 🎯 Scalability

The system is designed to handle:
- 100,000+ concurrent drivers
- 10,000 ride requests/minute
- 200,000 location updates/second

See [SCALABILITY_ARCHITECTURE.md](SCALABILITY_ARCHITECTURE.md) for details.

### Key Scale Features

- **Stateless API servers**: Horizontal scaling
- **Redis cluster**: Sharded for high throughput
- **PostgreSQL replicas**: Read/write separation
- **Multi-region deployment**: Region-local writes
- **Efficient caching**: Redis for hot data

## 🧪 Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/ride_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

## 🔒 Security

- JWT-based authentication
- Role-based authorization (Pundit)
- Tenant isolation
- Strong parameters
- SQL injection protection (ActiveRecord)
- XSS protection
- CORS configuration

## 📊 Monitoring

- **New Relic**: Application performance monitoring
- **Sidekiq Web**: Background job monitoring
- **Rails logs**: Structured logging
- **Redis**: Metrics and health checks

## 🚀 Deployment

### Docker

```bash
# Build image
docker build -t ridehailing-app .

# Run container
docker run -p 3000:3000 ridehailing-app
```

### Kubernetes

```bash
# Apply configurations
kubectl apply -f k8s/

# Scale API servers
kubectl scale deployment ridehailing-api --replicas=20
```

## 📚 Additional Documentation

- [RAILS_BEST_PRACTICES.md](RAILS_BEST_PRACTICES.md) - Rails conventions used
- [SCALABILITY_ARCHITECTURE.md](SCALABILITY_ARCHITECTURE.md) - Scale architecture
- [MULTI_REGION_ARCHITECTURE.md](MULTI_REGION_ARCHITECTURE.md) - Multi-region setup
- [SIMPLIFICATION_SUMMARY.md](SIMPLIFICATION_SUMMARY.md) - Code simplification details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For questions or issues:
- Open an issue on GitHub
- Contact: support@ridehailing.com

---

Built with ❤️ using Ruby on Rails
