class CreateDriverLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :driver_locations, id: :uuid do |t|
      t.references :driver, type: :uuid, foreign_key: true, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.decimal :bearing, precision: 5, scale: 2
      t.decimal :speed, precision: 5, scale: 2
      t.decimal :accuracy, precision: 5, scale: 2
      t.datetime :recorded_at, null: false
      
      t.timestamps
      
      t.index :driver_id
      t.index :recorded_at
      t.index [:driver_id, :recorded_at], order: { recorded_at: :desc }
      t.index [:latitude, :longitude]
    end
  end
end

