# Authorization policy for Trip resources
# Determines who can view and manage trips
class TripPolicy < ApplicationPolicy
  # Rider or driver associated with the trip can view it
  def show?
    rider_or_driver?
  end

  # Only the driver can end a trip
  def end_trip?
    driver?
  end

  # Only admins or super_admins can destroy
  def destroy?
    user&.admin? || user&.super_admin?
  end

  # Scope for filtering trips based on user role
  class Scope < Scope
    def resolve
      if user.rider?
        scope.joins(:ride).where(rides: { rider_id: user.rider.id })
      elsif user.driver?
        scope.joins(:ride).where(rides: { driver_id: user.driver.id })
      elsif user.admin? || user.super_admin?
        scope.all
      else
        scope.none
      end
    end
  end

  private

  def rider?
    record.ride.rider_id == user.rider&.id
  end

  def driver?
    record.ride.driver_id == user.driver&.id
  end

  def rider_or_driver?
    rider? || driver?
  end
end

