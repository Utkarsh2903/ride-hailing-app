# Concern for automatic tenant scoping in models
# Ensures all queries are automatically filtered by current tenant
module TenantScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :tenant
    validates :tenant_id, presence: true

    # Automatically scope all queries to current tenant
    default_scope { where(tenant_id: Tenant.current_id) if Tenant.current_id }

    # Set tenant_id before validation
    before_validation :set_tenant_id, on: :create

    # Validate tenant consistency
    validate :tenant_cannot_change, on: :update
  end

  class_methods do
    # Bypass tenant scoping for specific queries
    def all_tenants
      unscoped
    end

    # Query specific tenant
    def for_tenant(tenant)
      unscoped.where(tenant_id: tenant.id)
    end

    # Get records across all tenants (admin use)
    def cross_tenant
      unscoped
    end
  end

  private

  def set_tenant_id
    self.tenant_id ||= Tenant.current_id
  end

  def tenant_cannot_change
    return unless tenant_id_changed? && persisted?
    
    errors.add(:tenant_id, 'cannot be changed')
  end
end

