# Enable PostGIS extension for geospatial features
class EnablePostgis < ActiveRecord::Migration[7.1]
  def up
    enable_extension 'postgis'
    enable_extension 'uuid-ossp'
  end

  def down
    disable_extension 'postgis'
    disable_extension 'uuid-ossp'
  end
end

