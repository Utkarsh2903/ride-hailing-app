# Serializer for Tenant responses
class TenantSerializer
  include JSONAPI::Serializer

  attributes :slug, :name, :subdomain, :custom_domain, :status,
             :region, :country_code, :timezone, :currency,
             :plan_type

  attribute :business_info do |tenant|
    {
      name: tenant.business_name,
      email: tenant.business_email,
      support_phone: tenant.support_phone,
      support_email: tenant.support_email
    }
  end

  attribute :subscription do |tenant|
    {
      starts_at: tenant.subscription_starts_at&.iso8601,
      ends_at: tenant.subscription_ends_at&.iso8601,
      active: tenant.subscription_active?
    }
  end

  attribute :quotas do |tenant|
    {
      max_drivers: tenant.max_drivers,
      max_riders: tenant.max_riders,
      max_rides_per_month: tenant.max_rides_per_month
    }
  end

  attribute :created_at do |tenant|
    tenant.created_at.iso8601
  end
end

