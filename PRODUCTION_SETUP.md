# Production Environment Setup Guide

This application runs **exclusively in production mode** for consistency across all environments.

## 🎯 Environment Configuration

### Automatic Mode (Default)

The `.railsrc` file automatically forces production mode for all Rails commands:

```bash
rails console    # → runs in production
rails server     # → runs in production
rails db:migrate # → runs in production
```

### Manual Mode

If you need explicit control, always export these variables:

```bash
export RAILS_ENV=production
export RACK_ENV=production
```

Add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
# Force production mode for Ride Hailing App
export RAILS_ENV=production
export RACK_ENV=production
```

## 🚀 Quick Setup (Automated)

Run the automated setup script:

```bash
./bin/setup_production
```

This will:
1. ✅ Create `.env` file with production settings
2. ✅ Generate `SECRET_KEY_BASE`
3. ✅ Install dependencies (excluding dev/test gems)
4. ✅ Setup PostgreSQL database
5. ✅ Run all migrations
6. ✅ Enable PostGIS extensions

## 🔧 Manual Setup

### Step 1: Environment Variables

Create a `.env` file in the project root:

```bash
# Core settings
RAILS_ENV=production
RACK_ENV=production

# Database (adjust for your PostgreSQL setup)
DATABASE_URL=postgresql://localhost/ride_hailing_production

# Redis (adjust for your Redis setup)
REDIS_URL=redis://localhost:6379/0

# Security (generate with: bundle exec rails secret)
SECRET_KEY_BASE=<your_generated_secret>

# Server
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
PORT=8080

# CORS (adjust for your frontend)
CORS_ORIGINS=*
```

### Step 2: Database Setup

```bash
# Create database
bundle exec rails db:create

# Run migrations
bundle exec rails db:migrate

# Verify PostGIS is enabled
bundle exec rails runner "
  ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')
  ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"')
"
```

### Step 3: Create Initial Data

```bash
bundle exec rails runner "
tenant = Tenant.create!(
  subdomain: 'test',
  name: 'Test Company',
  status: 'active',
  default_payment_provider: 'stripe'
)

user = User.create!(
  tenant: tenant,
  email: 'admin@test.com',
  password: 'password123',
  role: 'super_admin',
  status: 'active'
)

puts '✅ Tenant: #{tenant.subdomain}'
puts '✅ User: #{user.email}'
"
```

## 🏃 Running the Application

### Start Web Server

```bash
bundle exec rails server
# or with explicit port
PORT=8080 bundle exec rails server
```

### Start Background Workers

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

### Access Rails Console

```bash
bundle exec rails console
# Automatically runs in production mode
```

## 🧪 Testing the Setup

### Health Check

```bash
curl http://localhost:8080/health
```

### Login Test

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: test" \
  -d '{
    "email": "admin@test.com",
    "password": "password123"
  }'
```

You should receive a JWT token in the response.

## 🔐 Security Checklist

- [ ] `SECRET_KEY_BASE` is unique and not committed to Git
- [ ] `RAILS_MASTER_KEY` is secure (from `config/master.key`)
- [ ] Database uses strong password
- [ ] Redis has authentication enabled (if exposed)
- [ ] CORS is configured for your specific frontend domain (not `*`)
- [ ] `.env` file is in `.gitignore`

## 🐳 Docker (Optional)

If you prefer Docker:

```bash
# Build
docker build -t ride-hailing-app .

# Run
docker run -p 8080:8080 \
  -e DATABASE_URL=postgresql://host.docker.internal/ride_hailing_production \
  -e REDIS_URL=redis://host.docker.internal:6379/0 \
  -e SECRET_KEY_BASE=your_secret \
  ride-hailing-app
```

## 🚀 Railway Deployment

The app is pre-configured for Railway:

1. Push to GitHub
2. Connect Railway to your repo
3. Add PostgreSQL + Redis services
4. Set `SECRET_KEY_BASE` and `RAILS_MASTER_KEY`
5. Deploy! (Migrations run automatically via `Procfile`)

## 📊 Monitoring

- **Logs**: `tail -f log/production.log`
- **Console**: `bundle exec rails console`
- **New Relic**: Configure `NEW_RELIC_LICENSE_KEY` in `.env`

## 🆘 Troubleshooting

### "Database does not exist"
```bash
bundle exec rails db:create
```

### "Could not connect to Redis"
```bash
# Check Redis is running
redis-cli ping
# Should return: PONG
```

### "Migrations are pending"
```bash
bundle exec rails db:migrate
```

### "Permission denied: ./bin/setup_production"
```bash
chmod +x ./bin/setup_production
```

## 📝 Important Notes

- **No development/test mode**: Only production gems are installed
- **No Swagger docs**: Removed for simplicity
- **No ActionCable**: API-only, no WebSockets
- **Stateless**: JWT-based auth, no sessions

---

**Ready to Deploy?** See `RAILWAY_MANUAL_STEPS.md` for step-by-step Railway deployment.

