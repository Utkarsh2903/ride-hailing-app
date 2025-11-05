# Remove PostGIS geography columns - we use lat/lng decimals instead
class RemoveGeographyColumns < ActiveRecord::Migration[7.1]
  def up
    # Driver locations - remove geography column (already has lat/lng)
    remove_column :driver_locations, :location if column_exists?(:driver_locations, :location)
    
    # Rides - remove geography columns (already has lat/lng)
    remove_column :rides, :pickup_location if column_exists?(:rides, :pickup_location)
    remove_column :rides, :dropoff_location if column_exists?(:rides, :dropoff_location)
  end

  def down
    # No rollback needed - we don't want to re-add PostGIS columns
    # If needed, manually add them back with PostGIS enabled
  end
end

