class SimplifyModelsWithEnums < ActiveRecord::Migration[7.1]
  def up
    # Users: Convert strings to enums (integers)
    add_column :users, :role_enum, :integer, default: 0, null: false
    add_column :users, :status_enum, :integer, default: 0, null: false
    
    # Migrate existing data
    execute <<-SQL
      UPDATE users SET role_enum = CASE role
        WHEN 'rider' THEN 0
        WHEN 'driver' THEN 1
        WHEN 'admin' THEN 2
        WHEN 'super_admin' THEN 3
        ELSE 0
      END;
      
      UPDATE users SET status_enum = CASE status
        WHEN 'active' THEN 0
        WHEN 'suspended' THEN 1
        WHEN 'inactive' THEN 2
        ELSE 0
      END;
    SQL
    
    # Remove old columns and metadata
    remove_column :users, :role
    remove_column :users, :status
    remove_column :users, :metadata
    
    # Rename enum columns
    rename_column :users, :role_enum, :role
    rename_column :users, :status_enum, :status
    
    # Drivers: Convert vehicle_type to enum
    add_column :drivers, :vehicle_type_enum, :integer, default: 1, null: false
    
    execute <<-SQL
      UPDATE drivers SET vehicle_type_enum = CASE vehicle_type
        WHEN 'economy' THEN 0
        WHEN 'standard' THEN 1
        WHEN 'premium' THEN 2
        WHEN 'suv' THEN 3
        WHEN 'luxury' THEN 4
        ELSE 1
      END;
    SQL
    
    remove_column :drivers, :vehicle_type
    remove_column :drivers, :documents
    remove_column :drivers, :metadata
    rename_column :drivers, :vehicle_type_enum, :vehicle_type
    
    # Riders: Convert payment method to enum, remove unused columns
    add_column :riders, :preferred_payment_method_enum, :integer, default: 0, null: false
    
    execute <<-SQL
      UPDATE riders SET preferred_payment_method_enum = CASE preferred_payment_method
        WHEN 'card' THEN 0
        WHEN 'cash' THEN 1
        WHEN 'wallet' THEN 2
        ELSE 0
      END;
    SQL
    
    remove_column :riders, :preferred_payment_method
    remove_column :riders, :saved_addresses
    remove_column :riders, :metadata
    rename_column :riders, :preferred_payment_method_enum, :preferred_payment_method
    
    # Rides: Convert enums and remove unnecessary columns
    add_column :rides, :tier_enum, :integer, default: 1, null: false
    add_column :rides, :payment_method_enum, :integer, default: 0, null: false
    add_column :rides, :payment_status_enum, :integer, default: 0
    add_column :rides, :cancelled_by_enum, :integer
    
    execute <<-SQL
      UPDATE rides SET tier_enum = CASE tier
        WHEN 'economy' THEN 0
        WHEN 'standard' THEN 1
        WHEN 'premium' THEN 2
        WHEN 'suv' THEN 3
        WHEN 'luxury' THEN 4
        ELSE 1
      END;
      
      UPDATE rides SET payment_method_enum = CASE payment_method
        WHEN 'card' THEN 0
        WHEN 'cash' THEN 1
        WHEN 'wallet' THEN 2
        ELSE 0
      END;
      
      UPDATE rides SET payment_status_enum = CASE payment_status
        WHEN 'pending' THEN 0
        WHEN 'paid' THEN 1
        WHEN 'failed' THEN 2
        WHEN 'refunded' THEN 3
        ELSE 0
      END;
      
      UPDATE rides SET cancelled_by_enum = CASE cancelled_by
        WHEN 'rider' THEN 0
        WHEN 'driver' THEN 1
        WHEN 'system' THEN 2
        ELSE NULL
      END;
    SQL
    
    remove_column :rides, :tier
    remove_column :rides, :payment_method
    remove_column :rides, :payment_status
    remove_column :rides, :cancelled_by
    remove_column :rides, :pickup_address
    remove_column :rides, :dropoff_address
    remove_column :rides, :cancellation_reason
    remove_column :rides, :metadata
    
    rename_column :rides, :tier_enum, :tier
    rename_column :rides, :payment_method_enum, :payment_method
    rename_column :rides, :payment_status_enum, :payment_status
    rename_column :rides, :cancelled_by_enum, :cancelled_by
    
    # Trips: Remove unnecessary columns
    remove_column :trips, :paused_at
    remove_column :trips, :resumed_at
    remove_column :trips, :discount_amount
    remove_column :trips, :route_coordinates
    remove_column :trips, :metadata
    
    # Payments: Convert to enums and remove unnecessary columns
    add_column :payments, :payment_method_enum, :integer, default: 0, null: false
    
    execute <<-SQL
      UPDATE payments SET payment_method_enum = CASE payment_method
        WHEN 'card' THEN 0
        WHEN 'cash' THEN 1
        WHEN 'wallet' THEN 2
        ELSE 0
      END;
    SQL
    
    remove_column :payments, :payment_method
    remove_column :payments, :currency  # Always USD
    remove_column :payments, :payment_provider
    remove_column :payments, :payment_provider_status
    remove_column :payments, :payment_provider_response
    remove_column :payments, :failure_reason
    remove_column :payments, :metadata
    rename_column :payments, :payment_method_enum, :payment_method
    
    # DriverAssignments: Remove decline_reason
    remove_column :driver_assignments, :decline_reason
    
    # Notifications: Convert to enums
    add_column :notifications, :channel_enum, :integer
    add_column :notifications, :status_enum, :integer, default: 0, null: false
    
    execute <<-SQL
      UPDATE notifications SET status_enum = CASE status
        WHEN 'pending' THEN 0
        WHEN 'sent' THEN 1
        WHEN 'delivered' THEN 2
        WHEN 'failed' THEN 3
        ELSE 0
      END;
    SQL
    
    remove_column :notifications, :channel
    remove_column :notifications, :status
    rename_column :notifications, :channel_enum, :channel
    rename_column :notifications, :status_enum, :status
    
    # Add indexes on enum columns for performance
    add_index :users, :role
    add_index :users, :status
    add_index :drivers, :vehicle_type
    add_index :rides, :tier
    add_index :rides, :payment_method
    add_index :rides, :payment_status
    add_index :payments, :payment_method
    add_index :notifications, :status
  end

  def down
    # Reverse migration not needed for simplification
    raise ActiveRecord::IrreversibleMigration
  end
end

