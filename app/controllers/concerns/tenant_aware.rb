# Concern for resolving and setting current tenant in controllers
module TenantAware
  extend ActiveSupport::Concern

  included do
    before_action :set_current_tenant
    after_action :clear_current_tenant
  end

  private

  def set_current_tenant
    tenant = resolve_tenant
    
    raise NotFoundError.new('Tenant not found or invalid') unless tenant
    raise AuthorizationError.new('This tenant is currently inactive') unless tenant.active?

    Tenant.current = tenant
  end

  def clear_current_tenant
    Tenant.current = nil
  end

  def resolve_tenant
    # Priority order:
    # 1. JWT token (most secure)
    # 2. API Header
    # 3. Subdomain
    # 4. Custom domain
    
    tenant_from_jwt || 
      tenant_from_header || 
      tenant_from_subdomain || 
      tenant_from_custom_domain
  end

  def tenant_from_jwt
    return nil unless current_user
    current_user.tenant
  end

  def tenant_from_header
    tenant_id = request.headers['X-Tenant-ID']
    return nil unless tenant_id

    Tenant.unscoped.find_by(id: tenant_id) ||
      Tenant.unscoped.find_by(slug: tenant_id)
  end

  def tenant_from_subdomain
    return nil unless request.subdomain.present?
    return nil if request.subdomain == 'www'

    Tenant.unscoped.find_by(subdomain: request.subdomain)
  end

  def tenant_from_custom_domain
    return nil unless request.domain.present?

    Tenant.unscoped.find_by(custom_domain: request.host)
  end

  def current_tenant
    Tenant.current
  end

  # Helper to execute code in different tenant context
  def with_tenant(tenant)
    previous_tenant = Tenant.current
    Tenant.current = tenant
    yield
  ensure
    Tenant.current = previous_tenant
  end

  # Check if user belongs to current tenant
  def verify_tenant_access!
    return unless current_user

    if current_user.tenant_id != Tenant.current_id
      raise AuthorizationError.new('You do not have access to this tenant')
    end
  end
end
