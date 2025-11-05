class CreateDriverAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :driver_assignments, id: :uuid do |t|
      t.references :ride, type: :uuid, foreign_key: true, null: false
      t.references :driver, type: :uuid, foreign_key: true, null: false
      t.string :status, null: false, default: 'offered'
      t.decimal :distance_to_pickup, precision: 10, scale: 2
      t.integer :eta_to_pickup
      t.datetime :offered_at
      t.datetime :accepted_at
      t.datetime :declined_at
      t.datetime :expired_at
      t.datetime :timeout_at
      t.string :decline_reason
      
      t.timestamps
      
      t.index :ride_id, name: 'idx_assignments_on_ride'
      t.index :driver_id, name: 'idx_assignments_on_driver'
      t.index :status, name: 'idx_assignments_on_status'
      t.index :offered_at, name: 'idx_assignments_on_offered_at'
      t.index [:ride_id, :driver_id], unique: true, name: 'idx_assignments_ride_driver_unique'
      t.index [:status, :offered_at], name: 'idx_assignments_status_offered'
    end
  end
end

