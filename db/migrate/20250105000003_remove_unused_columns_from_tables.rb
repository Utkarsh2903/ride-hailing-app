class RemoveUnusedColumnsFromTables < ActiveRecord::Migration[7.1]
  def change
    # Users: Remove first_name, last_name, metadata - add name instead
    remove_column :users, :first_name, :string if column_exists?(:users, :first_name)
    remove_column :users, :last_name, :string if column_exists?(:users, :last_name)
    remove_column :users, :metadata, :jsonb if column_exists?(:users, :metadata)
    add_column :users, :name, :string, null: false, default: '' unless column_exists?(:users, :name)
    
    # Tenants: Remove many unused columns
    remove_column :tenants, :custom_domain, :string if column_exists?(:tenants, :custom_domain)
    remove_column :tenants, :branding, :jsonb if column_exists?(:tenants, :branding)
    remove_column :tenants, :features, :jsonb if column_exists?(:tenants, :features)
    remove_column :tenants, :max_drivers, :integer if column_exists?(:tenants, :max_drivers)
    remove_column :tenants, :max_riders, :integer if column_exists?(:tenants, :max_riders)
    remove_column :tenants, :max_rides_per_month, :integer if column_exists?(:tenants, :max_rides_per_month)
    remove_column :tenants, :business_name, :string if column_exists?(:tenants, :business_name)
    remove_column :tenants, :business_email, :string if column_exists?(:tenants, :business_email)
    remove_column :tenants, :support_phone, :string if column_exists?(:tenants, :support_phone)
    remove_column :tenants, :support_email, :string if column_exists?(:tenants, :support_email)
    remove_column :tenants, :plan_type, :string if column_exists?(:tenants, :plan_type)
    remove_column :tenants, :subscription_starts_at, :datetime if column_exists?(:tenants, :subscription_starts_at)
    remove_column :tenants, :subscription_ends_at, :datetime if column_exists?(:tenants, :subscription_ends_at)
    remove_column :tenants, :deleted_at, :datetime if column_exists?(:tenants, :deleted_at)
    
    # Drivers: Remove many unused columns
    remove_column :drivers, :vehicle_plate, :string if column_exists?(:drivers, :vehicle_plate)
    remove_column :drivers, :vehicle_year, :integer if column_exists?(:drivers, :vehicle_year)
    remove_column :drivers, :total_trips, :integer if column_exists?(:drivers, :total_trips)
    remove_column :drivers, :acceptance_rate, :decimal if column_exists?(:drivers, :acceptance_rate)
    remove_column :drivers, :cancellation_rate, :decimal if column_exists?(:drivers, :cancellation_rate)
    remove_column :drivers, :verified_at, :datetime if column_exists?(:drivers, :verified_at)
    remove_column :drivers, :documents, :jsonb if column_exists?(:drivers, :documents)
    remove_column :drivers, :metadata, :jsonb if column_exists?(:drivers, :metadata)
    
    # Riders: Remove unused columns
    remove_column :riders, :total_trips, :integer if column_exists?(:riders, :total_trips)
    remove_column :riders, :metadata, :jsonb if column_exists?(:riders, :metadata)
    
    # Trips: Remove many fare-related columns
    remove_column :trips, :paused_at, :datetime if column_exists?(:trips, :paused_at)
    remove_column :trips, :resumed_at, :datetime if column_exists?(:trips, :resumed_at)
    remove_column :trips, :waiting_time, :decimal if column_exists?(:trips, :waiting_time)
    remove_column :trips, :waiting_charge, :decimal if column_exists?(:trips, :waiting_charge)
    remove_column :trips, :service_fee, :decimal if column_exists?(:trips, :service_fee)
    remove_column :trips, :tax_amount, :decimal if column_exists?(:trips, :tax_amount)
    remove_column :trips, :discount_amount, :decimal if column_exists?(:trips, :discount_amount)
    remove_column :trips, :tip_amount, :decimal if column_exists?(:trips, :tip_amount)
    remove_column :trips, :metadata, :jsonb if column_exists?(:trips, :metadata)
    
    # Payments: Remove unused columns
    remove_column :payments, :tax_amount, :decimal if column_exists?(:payments, :tax_amount)
    remove_column :payments, :metadata, :jsonb if column_exists?(:payments, :metadata)
    
    # Notifications: Remove 'read' boolean (we use 'read_at' datetime instead)
    remove_column :notifications, :read, :boolean if column_exists?(:notifications, :read)
    
    # Rides: metadata column should be removed
    remove_column :rides, :metadata, :jsonb if column_exists?(:rides, :metadata)
  end
end

