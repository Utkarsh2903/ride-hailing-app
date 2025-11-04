class CreateSurgeZones < ActiveRecord::Migration[7.1]
  def change
    create_table :surge_zones, id: :uuid do |t|
      t.string :name, null: false
      t.st_polygon :zone, geographic: true, null: false
      t.decimal :surge_multiplier, precision: 5, scale: 2, null: false, default: 1.0
      t.boolean :active, default: true
      t.integer :active_rides_count, default: 0
      t.integer :available_drivers_count, default: 0
      t.decimal :demand_supply_ratio, precision: 5, scale: 2
      t.datetime :activated_at
      t.datetime :deactivated_at
      
      t.jsonb :metadata, default: {}
      
      t.timestamps
      
      t.index :name
      t.index :active
      t.index :surge_multiplier
      t.index :zone, using: :gist
      t.index [:active, :surge_multiplier]
    end
  end
end

