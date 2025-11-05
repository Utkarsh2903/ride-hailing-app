# 🗺️ Enable PostGIS on Railway PostgreSQL

Railway's PostgreSQL by default doesn't have PostGIS enabled. You need to enable it manually first.

---

## 🚀 Method 1: Railway Dashboard (Easiest)

### Step 1: Access PostgreSQL Query Tab

1. Go to Railway Dashboard: https://railway.app/dashboard
2. Click on your **PostgreSQL** service (not your Rails app)
3. Click the **"Query"** tab at the top

### Step 2: Enable PostGIS Extension

Paste this SQL command and click **"Run Query"**:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Step 3: Verify Installation

Run this query to confirm:

```sql
SELECT PostGIS_version();
```

You should see the PostGIS version (e.g., `3.4 USE_GEOS=1 USE_PROJ=1...`)

### Step 4: Check Extensions

```sql
SELECT extname, extversion FROM pg_extension WHERE extname IN ('postgis', 'uuid-ossp');
```

Expected output:
```
extname    | extversion
-----------+------------
postgis    | 3.4.0
uuid-ossp  | 1.1
```

---

## 🔧 Method 2: Railway CLI

If you have the Railway CLI installed:

```bash
# Login
railway login

# Link to your project
railway link

# Run SQL command
railway run --service=postgresql psql -c "CREATE EXTENSION IF NOT EXISTS postgis;"
railway run --service=postgresql psql -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

# Verify
railway run --service=postgresql psql -c "SELECT PostGIS_version();"
```

---

## 🐛 Method 3: From Rails (Last Resort)

If the above methods don't work, you can try from your Rails app:

1. In Railway Dashboard, go to your **Rails app service**
2. Go to **"Deployments"** tab
3. Click the most recent successful deployment
4. Click **"View Logs"**
5. Look for this section:

```
🧩 Creating PostGIS and UUID extensions...
```

If you see an error like:
```
PG::InsufficientPrivilege: ERROR: permission denied to create extension "postgis"
```

This means your database user doesn't have superuser permissions. You MUST use Method 1 or 2.

---

## ✅ Verify PostGIS is Working

After enabling PostGIS, redeploy your app:

```bash
git commit --allow-empty -m "Trigger redeploy"
git push origin main
```

Then test from your Rails app console:

1. In Railway Dashboard → Your Rails app → **"..."** menu → **"Run Command"**
2. Enter: `rails console`
3. Run these commands:

```ruby
# Check PostGIS version
ActiveRecord::Base.connection.execute("SELECT PostGIS_version();").first

# Test creating a point
point = RGeo::Geographic.spherical_factory(srid: 4326).point(77.5946, 12.9716)
puts point.to_s  # Should print: POINT (77.5946 12.9716)

# Test database can store geometry
result = ActiveRecord::Base.connection.execute("SELECT ST_MakePoint(77.5946, 12.9716) as geom;")
puts result.first  # Should return geometry data
```

If all commands work without errors, PostGIS is properly configured! ✅

---

## 🆘 Troubleshooting

### Error: "could not open extension control file"

**Cause:** Railway's PostgreSQL image doesn't have PostGIS pre-installed.

**Solution:** Railway should have PostGIS by default. If not, you may need to:
1. Delete the PostgreSQL service
2. Create a new one
3. Railway's newer PostgreSQL templates include PostGIS

### Error: "permission denied to create extension"

**Cause:** Your database user lacks superuser privileges.

**Solution:** Use Method 1 (Railway Dashboard Query tab) - the dashboard has elevated permissions.

### Error: "extension 'postgis' already exists"

**Success!** ✅ PostGIS is already enabled. Ignore this error.

### PostGIS version mismatch warnings

If you see warnings about PostGIS versions, update the extension:

```sql
ALTER EXTENSION postgis UPDATE;
```

---

## 📊 Verify Your Migrations Work

After enabling PostGIS, test your migrations:

```bash
# Force a fresh migration (CAUTION: Drops all data!)
railway run --service=<your-rails-app> rails db:drop db:create db:migrate

# Or safer: Just run pending migrations
railway run --service=<your-rails-app> rails db:migrate
```

---

## 🎯 Why PostGIS is Required

Your app uses PostGIS for:

1. **Driver Locations** - `driver_locations` table has `location` column (geography type)
2. **Ride Coordinates** - `rides` table has `pickup_location` and `dropoff_location` (geography type)
3. **Geospatial Queries** - Distance calculations, radius searches
4. **Redis Geospatial** - Complements Redis GEORADIUS for persistent storage

---

## 🔍 Quick Check Queries

Once PostGIS is enabled, you can test these in the Query tab:

```sql
-- List all geometry columns in your database
SELECT f_table_name, f_geometry_column, type, srid
FROM geometry_columns;

-- Check if your tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Test PostGIS functions
SELECT ST_Distance(
  ST_MakePoint(77.5946, 12.9716)::geography,
  ST_MakePoint(77.6412, 12.9141)::geography
) / 1000 as distance_km;
```

---

**✅ Once Method 1 or 2 succeeds, your app will work properly!**

**Next:** Run `rails db:migrate` to create all tables with PostGIS types.

