# Authorization policy for Driver resources
# Determines who can perform driver-specific actions
class DriverPolicy < ApplicationPolicy
  # Drivers can view their own profile
  def show?
    owns_driver_profile? || admin?
  end

  # Only the driver can update their location
  def update_location?
    owns_driver_profile?
  end

  # Only the driver can batch update locations
  def batch_update_location?
    owns_driver_profile?
  end

  # Only the driver can accept rides
  def accept?
    owns_driver_profile?
  end

  # Only the driver can decline rides
  def decline?
    owns_driver_profile?
  end

  # Only the driver can mark arrived
  def mark_arrived?
    owns_driver_profile?
  end

  # Only the driver can start a trip
  def start_trip?
    owns_driver_profile?
  end

  # Only the driver can go online/offline
  def go_online?
    owns_driver_profile?
  end

  def go_offline?
    owns_driver_profile?
  end

  # Only the driver can view their earnings
  def earnings?
    owns_driver_profile? || admin?
  end

  # Admins can view all drivers
  def index?
    admin?
  end

  # Scope for filtering drivers based on user role
  class Scope < Scope
    def resolve
      if user.driver?
        scope.where(id: user.driver.id)
      elsif user.admin? || user.super_admin?
        scope.all
      else
        scope.none
      end
    end
  end

  private

  def owns_driver_profile?
    user&.driver? && record.id == user.driver.id
  end

  def admin?
    user&.admin? || user&.super_admin?
  end
end

