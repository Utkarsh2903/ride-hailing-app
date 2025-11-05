-- Run this SQL in Railway to reset your database
-- This will drop all tables and start fresh

-- Drop all tables
DROP TABLE IF EXISTS schema_migrations CASCADE;
DROP TABLE IF EXISTS ar_internal_metadata CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS driver_assignments CASCADE;
DROP TABLE IF EXISTS surge_zones CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS trips CASCADE;
DROP TABLE IF EXISTS rides CASCADE;
DROP TABLE IF EXISTS driver_locations CASCADE;
DROP TABLE IF EXISTS riders CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS tenants CASCADE;

-- Drop any remaining indexes
DROP INDEX IF EXISTS index_driver_locations_on_driver_id CASCADE;

-- Verify all tables are gone
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';
-- Should return empty or only Railway system tables

