class AlignSchemaWithModelAnnotations < ActiveRecord::Migration[7.1]
  def up
    # Trips: Remove columns not in schema annotation
    # Schema annotation only has: id, ride_id, status, started_at, ended_at, actual_distance,
    # actual_duration, base_fare, distance_fare, time_fare, surge_amount, total_fare,
    # route_coordinates, tenant_id, created_at, updated_at
    remove_column :trips, :waiting_time, if_exists: true
    remove_column :trips, :waiting_charge, if_exists: true
    remove_column :trips, :service_fee, if_exists: true
    remove_column :trips, :tax_amount, if_exists: true
    remove_column :trips, :tip_amount, if_exists: true
    
    # Riders: Remove PSP columns not in schema annotation
    # Schema annotation only has: id, user_id, rating, completed_trips, cancelled_trips,
    # preferred_payment_method, saved_addresses, tenant_id, created_at, updated_at
    remove_column :riders, :stripe_customer_id, if_exists: true
    remove_column :riders, :stripe_payment_method_id, if_exists: true
    remove_column :riders, :paypal_customer_id, if_exists: true
    remove_column :riders, :braintree_customer_id, if_exists: true
    remove_column :riders, :braintree_payment_method_token, if_exists: true
    remove_column :riders, :preferred_payment_provider, if_exists: true
    
    # Drivers: Remove columns not in schema annotation
    # Schema annotation has: vehicle_type, vehicle_model, vehicle_plate
    # But migrations/code have: vehicle_type, vehicle_make, vehicle_model, vehicle_year,
    # vehicle_color, license_plate, verified_at, acceptance_rate, cancellation_rate
    remove_column :drivers, :vehicle_make, if_exists: true
    remove_column :drivers, :vehicle_color, if_exists: true
    remove_column :drivers, :verified_at, if_exists: true
    remove_column :drivers, :acceptance_rate, if_exists: true
    remove_column :drivers, :cancellation_rate, if_exists: true
    
    # Rename license_plate to vehicle_plate if it exists
    if column_exists?(:drivers, :license_plate) && !column_exists?(:drivers, :vehicle_plate)
      rename_column :drivers, :license_plate, :vehicle_plate
    elsif column_exists?(:drivers, :license_plate)
      remove_column :drivers, :license_plate
    end
    
    # Driver Assignments: Remove decline_reason (already removed in simplification)
    remove_column :driver_assignments, :decline_reason, if_exists: true
    
    # Rides: Remove columns not in schema annotation
    # Schema annotation has: pickup_address, dropoff_address, cancellation_reason
    # These are in the schema, so they're fine
    
    # Payments: Ensure we have currency and payment_provider fields
    # (Already correct based on payment.rb schema annotation)
    
    # Tenants: Remove columns not in schema annotation (already simplified)
    remove_column :tenants, :deleted_at, if_exists: true
    
    # Users: Schema annotation shows 'phone' and 'name' as strings,
    # but code references 'phone_number', 'first_name', 'last_name'
    # and 'role'/'status' as enums (integers)
    # Keep what's in the database from the simplification migration
    
    # Remove indexes on deleted columns
    remove_index :riders, :stripe_customer_id, if_exists: true
    remove_index :riders, :paypal_customer_id, if_exists: true
    remove_index :riders, :braintree_customer_id, if_exists: true
    remove_index :riders, :preferred_payment_provider, if_exists: true
    remove_index :payments, :payment_provider, if_exists: true
    remove_index :payments, :payment_provider_status, if_exists: true
  end
  
  def down
    # This migration is not reversible as it removes data
    raise ActiveRecord::IrreversibleMigration
  end
end

