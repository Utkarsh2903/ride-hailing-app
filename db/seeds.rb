# Database seeds for production environment
# Creates default tenant and super admin user

puts "🌱 Seeding database..."

# Create default tenant
tenant = Tenant.find_or_create_by!(slug: 'test') do |t|
  t.name = 'Test Tenant'
  t.subdomain = 'test'
  t.status = 'active'
  t.region = 'us-west'
  t.country_code = 'US'
  t.timezone = 'America/Los_Angeles'
  t.currency = 'USD'
  t.settings = {}
  t.pricing_config = {
    base_fare: 2.5,
    per_km: 1.5,
    per_minute: 0.3,
    minimum_fare: 5.0,
    currency: 'USD'
  }
  puts "  ✅ Created tenant: #{t.name}"
end

# Create super admin user (no tenant association)
super_admin = User.find_or_initialize_by(email: 'admin@test.com') do |u|
  u.phone = '+10000000000'
  u.password = 'Admin@123'
  u.password_confirmation = 'Admin@123'
  u.name = 'Super Admin'
  u.role = 'super_admin'
  u.status = 'active'
  u.tenant_id = nil  # Super admin has no tenant
end

if super_admin.new_record?
  super_admin.save!
  puts "  ✅ Created super admin: #{super_admin.email}"
else
  puts "  ℹ️  Super admin already exists: #{super_admin.email}"
end

puts "🎉 Seeding completed!"
puts ""
puts "📋 Default Credentials:"
puts "  Tenant ID: test"
puts "  Admin Email: admin@test.com"
puts "  Admin Password: Admin@123"
puts ""
