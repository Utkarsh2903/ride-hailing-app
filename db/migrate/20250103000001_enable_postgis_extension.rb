class EnablePostgisExtension < ActiveRecord::Migration[7.1]
  def change
    enable_extension "postgis"
    enable_extension "uuid-ossp"
  end
end

