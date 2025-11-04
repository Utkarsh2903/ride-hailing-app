# Authorization policy for Payment resources
# Determines who can view, create, retry, and refund payments
class PaymentPolicy < ApplicationPolicy
  # Only riders can create payments for their rides
  def create?
    user&.rider? && ride_belongs_to_rider?
  end

  # Rider or driver associated with the payment can view it
  def show?
    rider_or_driver?
  end

  # Rider or driver can view payments list
  def index?
    user&.rider? || user&.driver?
  end

  # Only the rider can retry a failed payment
  def retry_payment?
    rider? && record.retriable?
  end

  # Admins, super_admins, or the rider can refund
  def refund?
    (user&.admin? || user&.super_admin? || rider?) && record.completed?
  end

  # Only admins or super_admins can destroy
  def destroy?
    user&.admin? || user&.super_admin?
  end

  # Scope for filtering payments based on user role
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

  def ride_belongs_to_rider?
    # This is used for create action where we check the ride
    # The record would be the ride in this context
    record.is_a?(Ride) && record.rider_id == user.rider&.id
  end
end

