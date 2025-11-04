# Authorization policy for Tenant resources
# Only super admins can manage tenants
class TenantPolicy < ApplicationPolicy
  # Only super_admins can view tenants list
  def index?
    super_admin?
  end

  # Only super_admins can view tenant details
  def show?
    super_admin?
  end

  # Only super_admins can create tenants
  def create?
    super_admin?
  end

  # Only super_admins can update tenants
  def update?
    super_admin?
  end

  # Only super_admins can destroy tenants
  def destroy?
    super_admin?
  end

  # Only super_admins can view tenant stats
  def stats?
    super_admin?
  end

  # Scope for filtering tenants based on user role
  class Scope < Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.none
      end
    end
  end

  private

  def super_admin?
    user&.super_admin?
  end
end

