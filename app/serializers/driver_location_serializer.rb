# Serializer for Driver Location responses
class DriverLocationSerializer
  include JSONAPI::Serializer

  attributes :latitude, :longitude, :bearing, :speed, :accuracy

  attribute :updated_at do |location|
    location.recorded_at&.iso8601
  end
end

