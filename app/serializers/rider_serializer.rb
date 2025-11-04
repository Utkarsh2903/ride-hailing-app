# Serializer for Rider responses
class RiderSerializer
  include JSONAPI::Serializer

  attributes :rating, :total_trips, :completed_trips

  attribute :name do |rider|
    rider.user.full_name
  end

  attribute :phone do |rider|
    rider.user.phone
  end
end

