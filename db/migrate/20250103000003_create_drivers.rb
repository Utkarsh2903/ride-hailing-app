class CreateDrivers < ActiveRecord::Migration[7.1]
  def change
    create_table :drivers, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.string :license_number, null: false
      t.string :vehicle_type, null: false
      t.string :vehicle_model
      t.string :vehicle_plate, null: false
      t.integer :vehicle_year
      t.string :status, null: false, default: 'offline'
      t.decimal :rating, precision: 3, scale: 2, default: 5.0
      t.integer :total_trips, default: 0
      t.integer :accepted_trips, default: 0
      t.integer :completed_trips, default: 0
      t.integer :cancelled_trips, default: 0
      t.decimal :acceptance_rate, precision: 5, scale: 2, default: 100.0
      t.decimal :cancellation_rate, precision: 5, scale: 2, default: 0.0
      t.datetime :verified_at
      t.datetime :last_active_at
      t.jsonb :documents, default: {}
      t.jsonb :metadata, default: {}
      
      t.timestamps
      
      t.index :license_number, unique: true
      t.index :vehicle_plate, unique: true
      t.index :status
      t.index :rating
      t.index :last_active_at
      t.index :created_at
    end
  end
end

