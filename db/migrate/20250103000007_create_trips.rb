class CreateTrips < ActiveRecord::Migration[7.1]
  def change
    create_table :trips, id: :uuid do |t|
      t.references :ride, type: :uuid, foreign_key: true, null: false
      t.string :status, null: false, default: 'in_progress'
      
      # Actual trip data
      t.datetime :started_at
      t.datetime :paused_at
      t.datetime :resumed_at
      t.datetime :ended_at
      
      t.decimal :actual_distance, precision: 10, scale: 2
      t.integer :actual_duration
      t.decimal :waiting_time, precision: 10, scale: 2, default: 0
      
      # Fare breakdown
      t.decimal :base_fare, precision: 10, scale: 2
      t.decimal :distance_fare, precision: 10, scale: 2
      t.decimal :time_fare, precision: 10, scale: 2
      t.decimal :surge_amount, precision: 10, scale: 2, default: 0
      t.decimal :waiting_charge, precision: 10, scale: 2, default: 0
      t.decimal :service_fee, precision: 10, scale: 2, default: 0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.decimal :tip_amount, precision: 10, scale: 2, default: 0
      t.decimal :total_fare, precision: 10, scale: 2
      
      # Route tracking
      t.jsonb :route_coordinates, default: []
      
      t.jsonb :metadata, default: {}
      
      t.timestamps
      
      t.index :ride_id, unique: true
      t.index :status
      t.index :started_at
      t.index :ended_at
      t.index [:status, :started_at]
    end
  end
end

