class AddTenantToAllTables < ActiveRecord::Migration[7.1]
  def change
    # Add tenant_id to all domain tables
    tables = [
      :users,
      :drivers,
      :riders,
      :rides,
      :trips,
      :payments,
      :driver_locations,
      :surge_zones,
      :driver_assignments,
      :ratings,
      :notifications
    ]

    tables.each do |table|
      add_reference table, :tenant, type: :uuid, foreign_key: true, null: true
      add_index table, :tenant_id
    end

    # Composite indexes for common queries
    add_index :users, [:tenant_id, :email], unique: true, where: "tenant_id IS NOT NULL"
    add_index :users, [:tenant_id, :phone], unique: true, where: "tenant_id IS NOT NULL"
    add_index :users, [:tenant_id, :role]
    add_index :users, [:tenant_id, :status]

    add_index :drivers, [:tenant_id, :status]
    add_index :drivers, [:tenant_id, :last_active_at]

    add_index :rides, [:tenant_id, :status]
    add_index :rides, [:tenant_id, :rider_id]
    add_index :rides, [:tenant_id, :driver_id]
    add_index :rides, [:tenant_id, :created_at]

    add_index :trips, [:tenant_id, :status]
    add_index :trips, [:tenant_id, :driver_id]

    add_index :payments, [:tenant_id, :status]
    add_index :payments, [:tenant_id, :rider_id]

    add_index :driver_locations, [:tenant_id, :driver_id]
    add_index :driver_locations, [:tenant_id, :recorded_at]

    add_index :surge_zones, [:tenant_id, :active_from, :active_until]

    add_index :driver_assignments, [:tenant_id, :ride_id]
    add_index :driver_assignments, [:tenant_id, :driver_id]
    add_index :driver_assignments, [:tenant_id, :status]
  end
end

