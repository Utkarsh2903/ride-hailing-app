# 🚀 Quick Start Guide

**Production-Only Ride Hailing App**

---

## 📦 One-Command Setup

```bash
./bin/setup_production
```

This does everything:
- ✅ Creates `.env` file
- ✅ Generates secret keys
- ✅ Installs gems
- ✅ Creates database
- ✅ Runs migrations

---

## 🏃 Run Locally

```bash
# Terminal 1: Start web server
bundle exec rails server

# Terminal 2: Start worker
bundle exec sidekiq -C config/sidekiq.yml

# Terminal 3: Console
bundle exec rails console
```

**Note:** Always runs in production mode (configured in `.railsrc`)

---

## 🔧 Manual Setup

```bash
# 1. Environment
cat > .env << 'EOF'
RAILS_ENV=production
RACK_ENV=production
DATABASE_URL=postgresql://localhost/ride_hailing_production
REDIS_URL=redis://localhost:6379/0
RAILS_SERVE_STATIC_FILES=true
PORT=8080
EOF

# 2. Generate secret
bundle exec rails secret >> .env
# Edit .env and add: SECRET_KEY_BASE=<paste_secret>

# 3. Database
bundle exec rails db:create db:migrate

# 4. Test data
bundle exec rails runner "
tenant = Tenant.create!(subdomain: 'test', name: 'Test Co', status: 'active', default_payment_provider: 'stripe')
User.create!(tenant: tenant, email: 'admin@test.com', password: 'password123', role: 'super_admin', status: 'active')
"
```

---

## 🧪 Test API

```bash
# Health check
curl http://localhost:8080/health

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: test" \
  -d '{"email":"admin@test.com","password":"password123"}'

# Copy the token from response, then:
export TOKEN="your_jwt_token_here"

# Get current user
curl http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: test"
```

---

## 🚀 Deploy to Railway

### Quick Deploy

```bash
# 1. Push to GitHub
git push origin main

# 2. In Railway Dashboard:
# - New Project → Connect GitHub repo
# - Add PostgreSQL service
# - Add Redis service
# - Go to your app service → Variables → Add:
#   - SECRET_KEY_BASE (run: rails secret)
#   - RAILS_MASTER_KEY (from: config/master.key)
# - Deploy!

# 3. Wait for "Listening on http://0.0.0.0:8080"

# 4. Test
curl https://your-app.railway.app/health
```

**Migrations run automatically!** See `Procfile` release command.

---

## 📋 Common Commands

```bash
# Database
rails db:create          # Create database
rails db:migrate         # Run migrations
rails db:reset           # Drop, create, migrate
rails db:seed            # Load seed data

# Console
rails console            # Interactive console
rails runner "code"      # Run Ruby code

# Server
rails server             # Start web server
rails server -p 3000     # Custom port

# Jobs
sidekiq -C config/sidekiq.yml     # Start worker

# Logs
tail -f log/production.log        # Watch logs
```

---

## 🔑 Environment Variables

### Required
```bash
RAILS_ENV=production
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
SECRET_KEY_BASE=...
```

### Optional
```bash
PORT=8080                        # Server port
CORS_ORIGINS=*                   # CORS domains
RAILS_LOG_LEVEL=info            # Log verbosity
RAILS_MAX_THREADS=5             # Thread pool
NEW_RELIC_LICENSE_KEY=...       # Monitoring
```

---

## 📁 Key Files

```
.railsrc                    # Forces production mode
.env                        # Your local config
config/environments/production.rb
config/database.yml
config/initializers/redis.rb
config/initializers/sidekiq.rb
Procfile                    # Railway commands
railway.json               # Railway config
```

---

## 🆘 Troubleshooting

### "Bundle install fails"
```bash
gem install bundler
bundle install
```

### "Database connection error"
```bash
# Check PostgreSQL is running
psql -l

# Create database manually
createdb ride_hailing_production
```

### "Redis connection error"
```bash
# Check Redis is running
redis-cli ping
# Should return: PONG

# Start Redis (macOS)
brew services start redis
```

### "SECRET_KEY_BASE missing"
```bash
# Generate new secret
bundle exec rails secret

# Add to .env
echo "SECRET_KEY_BASE=<your_secret>" >> .env
```

### "Wrong environment"
Check `.railsrc` exists:
```bash
cat .railsrc
# Should show: --environment=production
```

---

## 📚 Documentation

- **Setup:** `PRODUCTION_SETUP.md` - Detailed setup guide
- **Verify:** `VERIFY_SETUP.md` - Checklist and verification
- **Changes:** `CHANGELOG_PRODUCTION.md` - What changed
- **Deploy:** `RAILWAY_MANUAL_STEPS.md` - Railway deployment
- **Main:** `README.md` - Overview and API docs

---

## 🎯 Next Steps

1. ✅ Setup complete? → Test the API
2. ✅ API working? → Deploy to Railway
3. ✅ Deployed? → Create test data
4. ✅ Data ready? → Load testing
5. ✅ All good? → Go live! 🎉

---

**Questions?** See detailed guides in the repo root.

**Issues?** Check `VERIFY_SETUP.md` for common solutions.

**Ready to deploy?** See `RAILWAY_MANUAL_STEPS.md`.

