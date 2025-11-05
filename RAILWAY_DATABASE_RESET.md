# 🔄 Railway Database Reset Instructions

Your database has partial migrations. Here's how to fix it:

---

## **🎯 Option 1: Delete & Recreate PostgreSQL (Easiest - 2 minutes)**

### **Steps:**

1. **Railway Dashboard** → https://railway.app/dashboard
2. Click your **PostgreSQL service**
3. **Settings** tab
4. Scroll to bottom
5. Click **"Delete Service"**
6. Confirm ✅
7. Click **"+ New"** button
8. **Database** → **Add PostgreSQL**
9. Wait 30 seconds ⏳
10. **Done!** Railway auto-connects it and redeploys your app

---

## **🎯 Option 2: Reset with SQL Commands**

### **If Railway has a Query interface:**

1. Railway Dashboard → Your **PostgreSQL service**
2. Look for **"Query"**, **"Data"**, or **"Connect"** tab
3. Paste this SQL:

```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```

4. Run the query ✅
5. Go to your **Rails app** → **Deployments**
6. Click **"Redeploy"** button

---

## **🎯 Option 3: Use Railway CLI**

### **If you have Railway CLI installed:**

```bash
# Connect to PostgreSQL
railway connect postgresql

# In psql, run:
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
\q

# Trigger redeploy
railway up --detach
```

---

## **🎯 Option 4: Manual Table Drop**

If other options don't work, Railway Dashboard → PostgreSQL → Query tab:

```sql
DROP TABLE IF EXISTS schema_migrations CASCADE;
DROP TABLE IF EXISTS ar_internal_metadata CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS driver_assignments CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS trips CASCADE;
DROP TABLE IF EXISTS rides CASCADE;
DROP TABLE IF EXISTS driver_locations CASCADE;
DROP TABLE IF EXISTS riders CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS tenants CASCADE;
```

Then redeploy your Rails app.

---

## **✅ After Reset**

Once database is reset, Railway will:

1. ✅ Redeploy your Rails app automatically
2. ✅ Run `rails db:prepare`
3. ✅ Create all tables fresh
4. ✅ Start your app successfully

Check deployment logs for:
```
✅ Running: rails db:prepare
✅ Migrated to CreateUsers
✅ Migrated to CreateDrivers
✅ ...
✅ Listening on http://0.0.0.0:8080
```

---

## **🧪 Create Test Data**

Railway Dashboard → Your Rails app → **"..."** → **"Run Command"**:

```bash
rails runner "
tenant = Tenant.create!(subdomain: 'test', name: 'Test Co', status: 'active', default_payment_provider: 'stripe')
User.create!(tenant: tenant, email: 'admin@test.com', password: 'password123', role: 'super_admin', status: 'active')
puts '✅ Setup complete'
"
```

---

## **🔍 Test Your App**

```bash
# Health check
curl https://your-app.railway.app/health

# Login
curl -X POST https://your-app.railway.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: test" \
  -d '{"email":"admin@test.com","password":"password123"}'
```

---

**Recommended: Option 1** - Delete and recreate PostgreSQL service (fastest!)

**Why this happened:** Previous migrations with PostGIS created partial tables, now we're using standard PostgreSQL and need a clean slate.

