class CreateRides < ActiveRecord::Migration[7.1]
  def change
    create_table :rides, id: :uuid do |t|
      t.references :rider, type: :uuid, foreign_key: true, null: false
      t.references :driver, type: :uuid, foreign_key: true
      t.string :status, null: false, default: 'requested'
      t.string :tier, null: false, default: 'standard'
      
      # Pickup location
      t.decimal :pickup_latitude, precision: 10, scale: 6, null: false
      t.decimal :pickup_longitude, precision: 10, scale: 6, null: false
      t.string :pickup_address
      
      # Dropoff location
      t.decimal :dropoff_latitude, precision: 10, scale: 6, null: false
      t.decimal :dropoff_longitude, precision: 10, scale: 6, null: false
      t.string :dropoff_address
      
      # Pricing
      t.decimal :estimated_fare, precision: 10, scale: 2
      t.decimal :surge_multiplier, precision: 5, scale: 2, default: 1.0
      t.decimal :estimated_distance, precision: 10, scale: 2
      t.integer :estimated_duration
      
      # Payment
      t.string :payment_method, null: false, default: 'card'
      t.string :payment_status, default: 'pending'
      
      # Timing
      t.datetime :requested_at
      t.datetime :accepted_at
      t.datetime :driver_arrived_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :cancelled_at
      t.string :cancelled_by
      t.string :cancellation_reason
      
      # Idempotency
      t.string :idempotency_key, null: false
      
      t.jsonb :metadata, default: {}
      
      t.timestamps
      
      t.index :rider_id, name: "idx_rides_rider_id"
      t.index :driver_id, name: "idx_rides_driver_id"
      t.index :status, name: "idx_rides_status"
      t.index :tier, name: "idx_rides_tier"
      t.index :requested_at, name: "idx_rides_requested_at"
      t.index :idempotency_key, unique: true, name: "idx_rides_idempotency_key"
      t.index [:pickup_latitude, :pickup_longitude], name: "idx_rides_pickup_coords"
      t.index [:dropoff_latitude, :dropoff_longitude], name: "idx_rides_dropoff_coords"
      t.index [:status, :requested_at], name: "idx_rides_status_requested"
      t.index [:rider_id, :created_at], order: { created_at: :desc }, name: "idx_rides_rider_created"
      t.index [:driver_id, :created_at], order: { created_at: :desc }, name: "idx_rides_driver_created"
    end
  end
end

