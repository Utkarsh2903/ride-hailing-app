# Serializer for Driver responses
class DriverSerializer
  include JSONAPI::Serializer

  attributes :rating, :total_trips, :completed_trips

  attribute :name do |driver|
    driver.user.full_name
  end

  attribute :phone do |driver|
    driver.user.phone
  end

  attribute :vehicle do |driver|
    {
      type: driver.vehicle_type,
      model: driver.vehicle_model,
      plate: driver.vehicle_plate,
      year: driver.vehicle_year
    }
  end

  attribute :status do |driver|
    driver.status
  end
end

