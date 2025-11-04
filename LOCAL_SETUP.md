# 🚀 Local Setup Guide - Ride Hailing App

Complete guide to set up and run the application on your Mac.

---

## 📋 Prerequisites

- **macOS** (you're using darwin 23.1.0)
- **Command line** access
- **Admin/sudo** access for installing dependencies

---

## ⚙️ Step 1: Install System Dependencies

### 1.1 Install Homebrew (if not installed)

```bash
# Check if Homebrew is installed
brew --version

# If not installed, run:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 1.2 Install Ruby via rbenv

```bash
# Install rbenv and ruby-build
brew install rbenv ruby-build

# Add rbenv to your shell profile
echo 'eval "$(rbenv init -)"' >> ~/.zshrc

# Reload your shell
source ~/.zshrc

# Install Ruby 3.2 or higher (check .ruby-version file)
rbenv install 3.2.2

# Set as global version
rbenv global 3.2.2

# Verify installation
ruby -v
# Should show: ruby 3.2.2

# Install Bundler
gem install bundler
```

### 1.3 Install PostgreSQL with PostGIS

```bash
# Install PostgreSQL 14+
brew install postgresql@16

# Install PostGIS extension
brew install postgis

# Start PostgreSQL service
brew services start postgresql@16

# Verify PostgreSQL is running
psql -d postgres -c "SELECT version();"
```

### 1.4 Install Redis

```bash
# Install Redis
brew install redis

# Start Redis service
brew services start redis

# Verify Redis is running
redis-cli ping
# Should return: PONG
```

---

## 🗄️ Step 2: Setup PostgreSQL Database

### 2.1 Create PostgreSQL User (if needed)

```bash
# Access PostgreSQL
psql postgres

# Inside psql, create a superuser (replace with your username)
CREATE USER your_username WITH SUPERUSER PASSWORD 'your_password';

# Exit psql
\q
```

### 2.2 Enable PostGIS Extension

```bash
# Create a test database and enable PostGIS
psql postgres

# Inside psql
CREATE EXTENSION IF NOT EXISTS postgis;

# Verify PostGIS is available
SELECT PostGIS_Version();

# Exit
\q
```

---

## 📦 Step 3: Setup Application

### 3.1 Navigate to Project Directory

```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"
```

### 3.2 Install Ruby Dependencies

```bash
# Install all gems
bundle install
```

**Common Issues:**

**If `pg` gem fails:**
```bash
gem install pg -- --with-pg-config=/opt/homebrew/bin/pg_config
bundle install
```

**If `rgeo` or PostGIS adapter fails:**
```bash
brew install geos proj
bundle config build.rgeo --with-geos-dir=/opt/homebrew/opt/geos
bundle install
```

### 3.3 Setup Rails Credentials

```bash
# Generate master key (if not exists)
# The master key should be in config/master.key
# If missing, create it:
EDITOR="nano" rails credentials:edit

# Add this content (minimum required):
secret_key_base: <paste output of: rails secret>

# Save and exit (Ctrl+X, then Y, then Enter in nano)
```

**Alternative editors:**
```bash
# Using VS Code
EDITOR="code --wait" rails credentials:edit

# Using Vim
EDITOR="vim" rails credentials:edit
```

### 3.4 Configure Database

Check `config/database.yml` - it should already be configured for development:

```yaml
development:
  adapter: postgis
  database: ride_hailing_development
  pool: 5
```

If you need a specific username/password, update it:

```yaml
development:
  adapter: postgis
  database: ride_hailing_development
  username: your_username
  password: your_password
  pool: 5
```

---

## 🗃️ Step 4: Create and Setup Database

```bash
# Create databases
rails db:create

# Output should be:
# Created database 'ride_hailing_development'
# Created database 'ride_hailing_test'

# Run migrations
rails db:migrate

# This will create all tables with proper schema
```

**Verify migrations:**
```bash
rails db:migrate:status

# All migrations should show "up"
```

---

## 🌱 Step 5: Seed Initial Data (Optional)

Create a seed file to test the app:

```bash
# Create seed file
cat > db/seeds.rb << 'EOF'
# Clear existing data (be careful in production!)
puts "Clearing existing data..."
# Don't clear in production!

# Create a tenant
puts "Creating tenant..."
tenant = Tenant.create!(
  slug: 'demo',
  name: 'Demo Ride Co',
  subdomain: 'demo',
  status: 'active',
  region: 'us-east-1',
  timezone: 'America/New_York',
  currency: 'USD'
)

puts "✅ Created tenant: #{tenant.name}"

# Set current tenant
Tenant.current = tenant

# Create a rider
puts "Creating rider..."
rider_user = User.create!(
  email: 'rider@example.com',
  phone_number: '+12025551234',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'John',
  last_name: 'Rider',
  role: 'rider',
  status: 'active'
)

rider = Rider.create!(
  user: rider_user,
  rating: 5.0,
  completed_trips: 0,
  cancelled_trips: 0,
  preferred_payment_method: 'card'
)

puts "✅ Created rider: #{rider_user.email}"

# Create a driver
puts "Creating driver..."
driver_user = User.create!(
  email: 'driver@example.com',
  phone_number: '+12025555678',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Jane',
  last_name: 'Driver',
  role: 'driver',
  status: 'active'
)

driver = Driver.create!(
  user: driver_user,
  license_number: 'DL123456',
  vehicle_type: 'standard',
  vehicle_model: 'Toyota Camry',
  vehicle_plate: 'ABC1234',
  vehicle_year: 2022,
  status: 'offline',
  rating: 4.8,
  total_trips: 0,
  accepted_trips: 0,
  completed_trips: 0,
  cancelled_trips: 0
)

puts "✅ Created driver: #{driver_user.email}"

puts "\n🎉 Seed data created successfully!"
puts "\n📝 Test Accounts:"
puts "Rider: rider@example.com / password123"
puts "Driver: driver@example.com / password123"
EOF

# Run seeds
rails db:seed
```

---

## 🚀 Step 6: Start the Application

You need **3 terminal windows/tabs**:

### Terminal 1: Rails Server

```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"
rails server

# Or on specific port:
rails s -p 3000
```

**Expected output:**
```
=> Booting Puma
=> Rails 7.1.3 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Puma version: 6.4.2 (ruby 3.2.2-p53) ("The Eagle of Durango")
* Min threads: 5
* Max threads: 5
* Environment: development
*          PID: 12345
* Listening on http://127.0.0.1:3000
Use Ctrl-C to stop
```

### Terminal 2: Sidekiq (Background Jobs)

```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"
bundle exec sidekiq

# Or with config:
bundle exec sidekiq -C config/sidekiq.yml
```

**Expected output:**
```
         m,
         `$b
    .ss,  $$:         .,d$
    `$$P,d$P'    .,md$P"'
     ,$$$$$b/md$$$P^'
   .d$$$$$$/$$$P'
   $$^' `"/$$$'       ____  _     _      _    _
   $:     ,$$:       / ___|(_) __| | ___| | _(_) __ _
   `b     :$$        \___ \| |/ _` |/ _ \ |/ / |/ _` |
          $$:         ___) | | (_| |  __/   <| | (_| |
          $$         |____/|_|\__,_|\___|_|\_\_|\__, |
        .d$$                                        |_|

2025-11-04T12:00:00.000Z pid=12346 tid=oxyz INFO: Sidekiq 7.2.0
2025-11-04T12:00:00.000Z pid=12346 tid=oxyz INFO: Booted Rails 7.1.3 application in development environment
2025-11-04T12:00:00.000Z pid=12346 tid=oxyz INFO: Running in ruby 3.2.2p53
```

### Terminal 3: Redis (if not running as service)

```bash
# Check if Redis is already running
redis-cli ping

# If it returns PONG, you're good!
# If not, start Redis manually:
redis-server
```

---

## ✅ Step 7: Verify Everything Works

### 7.1 Health Check

```bash
curl http://localhost:3000/up

# Should return: success
```

### 7.2 Test User Registration

```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "phone_number": "+12025559999",
    "first_name": "Test",
    "last_name": "User",
    "role": "rider"
  }'
```

### 7.3 Test Login

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Copy the JWT token from response
```

### 7.4 Test Creating a Ride

```bash
# Replace YOUR_JWT_TOKEN with the token from login
curl -X POST http://localhost:3000/api/v1/rides \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "pickup_latitude": 37.7749,
    "pickup_longitude": -122.4194,
    "pickup_address": "San Francisco, CA",
    "dropoff_latitude": 37.8044,
    "dropoff_longitude": -122.2712,
    "dropoff_address": "Oakland, CA",
    "tier": "standard",
    "payment_method": "card"
  }'
```

---

## 🧪 Step 8: Test in Rails Console

```bash
rails console

# Or
rails c
```

**Test commands:**
```ruby
# Check database connection
User.count
# => Should return number of users (at least 2 if you ran seeds)

# Check Redis connection
$redis.ping
# => "PONG"

# Create a test tenant
tenant = Tenant.create!(name: 'Test', slug: 'test', subdomain: 'test', status: 'active')

# Set current tenant
Tenant.current = tenant

# Check tenant
Tenant.current
# => #<Tenant id: "...", name: "Test", ...>

# Test geospatial query
DriverLocation.nearby_drivers(37.7749, -122.4194, 5)

# Exit console
exit
```

---

## 🔧 Step 9: Development Tools

### View Logs

```bash
# In another terminal
tail -f log/development.log

# Or with grep
tail -f log/development.log | grep ERROR
```

### Database Console

```bash
rails dbconsole

# Or
rails db
```

### Check Routes

```bash
rails routes

# Or filter
rails routes | grep rides
```

### Run Migrations Status

```bash
rails db:migrate:status
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Port 3000 Already in Use

```bash
# Find process using port 3000
lsof -ti:3000

# Kill the process
kill -9 $(lsof -ti:3000)

# Or run on different port
rails s -p 3001
```

### Issue 2: PostgreSQL Not Running

```bash
# Check status
brew services list | grep postgresql

# Restart
brew services restart postgresql@16

# Check connection
psql -d postgres -c "SELECT 1;"
```

### Issue 3: Redis Not Running

```bash
# Check if Redis is running
redis-cli ping

# If not running, start it
brew services start redis

# Or manually
redis-server
```

### Issue 4: PostGIS Extension Error

```bash
# Connect to your database
psql -d ride_hailing_development

# Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

# Verify
SELECT PostGIS_Version();

# Exit
\q
```

### Issue 5: Bundle Install Fails

```bash
# Update RubyGems
gem update --system

# Update Bundler
gem install bundler

# Clear cache
bundle clean --force
rm -rf vendor/bundle

# Try again
bundle install
```

### Issue 6: Database Creation Fails

```bash
# Drop and recreate
rails db:drop
rails db:create
rails db:migrate
rails db:seed
```

### Issue 7: Sidekiq Won't Start

```bash
# Check Redis is running
redis-cli ping

# Clear Redis
redis-cli FLUSHALL

# Restart Sidekiq
bundle exec sidekiq
```

---

## 📊 Verify Your Setup

Run this checklist:

- [ ] Ruby 3.2+ installed (`ruby -v`)
- [ ] PostgreSQL running (`psql -d postgres -c "SELECT 1;"`)
- [ ] PostGIS available (`psql -d postgres -c "SELECT PostGIS_Version();"`)
- [ ] Redis running (`redis-cli ping`)
- [ ] Gems installed (`bundle check`)
- [ ] Database created (`rails runner "puts User.count"`)
- [ ] Migrations run (`rails db:migrate:status`)
- [ ] Rails server starts (`curl http://localhost:3000/up`)
- [ ] Sidekiq starts (`ps aux | grep sidekiq`)
- [ ] Can create user (test registration endpoint)
- [ ] Can login (test login endpoint)
- [ ] Can create ride (test rides endpoint)

---

## 🎯 Quick Start Script

Save this as `bin/dev_setup` and make it executable:

```bash
#!/bin/bash
set -e

echo "🚀 Starting Ride Hailing App..."

# Check PostgreSQL
if ! brew services list | grep -q "postgresql@16.*started"; then
  echo "Starting PostgreSQL..."
  brew services start postgresql@16
fi

# Check Redis
if ! redis-cli ping > /dev/null 2>&1; then
  echo "Starting Redis..."
  brew services start redis
fi

echo "✅ All services running!"
echo ""
echo "Start these in separate terminals:"
echo "  Terminal 1: rails server"
echo "  Terminal 2: bundle exec sidekiq"
```

Make it executable:
```bash
chmod +x bin/dev_setup
```

Run it:
```bash
./bin/dev_setup
```

---

## 📚 Useful Commands

### Start Services
```bash
# PostgreSQL
brew services start postgresql@16

# Redis
brew services start redis

# Rails
rails server

# Sidekiq
bundle exec sidekiq
```

### Stop Services
```bash
# PostgreSQL
brew services stop postgresql@16

# Redis
brew services stop redis

# Rails (Ctrl+C in terminal)
# Sidekiq (Ctrl+C in terminal)
```

### Restart Services
```bash
brew services restart postgresql@16
brew services restart redis
```

### Check Service Status
```bash
brew services list
```

---

## 🎉 You're All Set!

Your local development environment is ready!

**Access points:**
- **API:** http://localhost:3000
- **Health Check:** http://localhost:3000/up
- **Rails Console:** `rails c`
- **Logs:** `tail -f log/development.log`

**Test accounts (if you ran seeds):**
- **Rider:** rider@example.com / password123
- **Driver:** driver@example.com / password123

**Next steps:**
1. Test all API endpoints
2. Create rides and test the flow
3. Test driver location updates
4. Test payment processing

---

## 📖 Additional Resources

- Rails Guides: https://guides.rubyonrails.org
- PostgreSQL Docs: https://www.postgresql.org/docs/
- PostGIS Docs: https://postgis.net/docs/
- Redis Docs: https://redis.io/docs/
- Sidekiq Docs: https://github.com/sidekiq/sidekiq/wiki

---

**Happy Coding! 🚀**

