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
      :driver_assignments,
      :notifications
    ]

    tables.each do |table|
      add_reference table, :tenant, type: :uuid, foreign_key: true, null: true
      add_index table, :tenant_id, name: "idx_#{table}_tenant_id"
    end

    # Composite indexes for common queries
    add_index :users, [:tenant_id, :email], unique: true, where: "tenant_id IS NOT NULL", name: "idx_users_tenant_email_unique"
    add_index :users, [:tenant_id, :phone], unique: true, where: "tenant_id IS NOT NULL", name: "idx_users_tenant_phone_unique"
    add_index :users, [:tenant_id, :role], name: "idx_users_tenant_role"
    add_index :users, [:tenant_id, :status], name: "idx_users_tenant_status"

    add_index :drivers, [:tenant_id, :status], name: "idx_drivers_tenant_status"
    add_index :drivers, [:tenant_id, :last_active_at], name: "idx_drivers_tenant_active"

    add_index :rides, [:tenant_id, :status], name: "idx_rides_tenant_status"
    add_index :rides, [:tenant_id, :rider_id], name: "idx_rides_tenant_rider"
    add_index :rides, [:tenant_id, :driver_id], name: "idx_rides_tenant_driver"
    add_index :rides, [:tenant_id, :created_at], name: "idx_rides_tenant_created"

    add_index :trips, [:tenant_id, :status], name: "idx_trips_tenant_status"
    add_index :trips, [:tenant_id, :driver_id], name: "idx_trips_tenant_driver"

    add_index :payments, [:tenant_id, :status], name: "idx_payments_tenant_status"
    add_index :payments, [:tenant_id, :rider_id], name: "idx_payments_tenant_rider"

    add_index :driver_locations, [:tenant_id, :driver_id], name: "idx_locations_tenant_driver"
    add_index :driver_locations, [:tenant_id, :recorded_at], name: "idx_locations_tenant_recorded"

    add_index :driver_assignments, [:tenant_id, :ride_id], name: "idx_assignments_tenant_ride"
    add_index :driver_assignments, [:tenant_id, :driver_id], name: "idx_assignments_tenant_driver"
    add_index :driver_assignments, [:tenant_id, :status], name: "idx_assignments_tenant_status"
  end
end

