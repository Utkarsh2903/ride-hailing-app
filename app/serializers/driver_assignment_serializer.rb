# Serializer for DriverAssignment responses
class DriverAssignmentSerializer
  include JSONAPI::Serializer

  attributes :status, :offered_at, :accepted_at, :declined_at, :expired_at

  attribute :ride, if: Proc.new { |assignment| assignment.ride.present? } do |assignment|
    RideSerializer.new(assignment.ride).serializable_hash[:data][:attributes]
  end

  attribute :driver, if: Proc.new { |assignment| assignment.driver.present? } do |assignment|
    DriverSerializer.new(assignment.driver).serializable_hash[:data][:attributes]
  end
end

