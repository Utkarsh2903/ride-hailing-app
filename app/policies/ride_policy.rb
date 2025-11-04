# Authorization policy for Ride resources
# Determines who can view, create, update, cancel, and track rides
class RidePolicy < ApplicationPolicy
  # Anyone authenticated can create rides if they're a rider
  def create?
    user&.rider?
  end

  # Rider or driver associated with the ride can view it
  def show?
    rider_or_driver?
  end

  # Rider or driver can view rides list
  def index?
    user&.rider? || user&.driver?
  end

  # Rider or driver can cancel the ride if it's in a cancellable state
  def cancel?
    rider_or_driver? && record.can_be_cancelled?
  end

  # Rider or driver can track the ride if it's trackable
  def track?
    rider_or_driver? && trackable?
  end

  # Only admins or super_admins can destroy
  def destroy?
    user&.admin? || user&.super_admin?
  end

  # Scope for filtering rides based on user role
  class Scope < Scope
    def resolve
      if user.rider?
        scope.where(rider_id: user.rider.id)
      elsif user.driver?
        scope.where(driver_id: user.driver.id)
      elsif user.admin? || user.super_admin?
        scope.all
      else
        scope.none
      end
    end
  end

  private

  def rider?
    record.rider_id == user.rider&.id
  end

  def driver?
    record.driver_id == user.driver&.id
  end

  def rider_or_driver?
    rider? || driver?
  end

  def trackable?
    record.accepted? || record.driver_arrived? || record.in_progress?
  end
end

