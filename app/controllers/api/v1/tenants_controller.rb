module Api
  module V1
    # Controller for tenant management (admin only)
    class TenantsController < BaseController
      skip_before_action :set_current_tenant, only: [:index, :show, :create]
      skip_before_action :verify_tenant_access!
      before_action :require_super_admin!

      # GET /api/v1/tenants
      def index
        tenants = Tenant.unscoped.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 20)
        
        render_collection(tenants, serializer: TenantSerializer)
      end

      # GET /api/v1/tenants/:id
      def show
        tenant = Tenant.unscoped.find(params[:id])
        
        render_success(
          TenantSerializer.new(tenant).serializable_hash,
          meta: tenant_stats(tenant)
        )
      end

      # POST /api/v1/tenants
      def create
        tenant = Tenant.create!(tenant_params)
        
        render_success(
          TenantSerializer.new(tenant).serializable_hash,
          status: :created
        )
      rescue ActiveRecord::RecordInvalid => e
        render_error(e.record.errors.full_messages, status: :unprocessable_entity)
      end

      # PATCH /api/v1/tenants/:id
      def update
        tenant = Tenant.unscoped.find(params[:id])
        tenant.update!(tenant_params)
        
        render_success(TenantSerializer.new(tenant).serializable_hash)
      rescue ActiveRecord::RecordInvalid => e
        render_error(e.record.errors.full_messages, status: :unprocessable_entity)
      end

      # DELETE /api/v1/tenants/:id
      def destroy
        tenant = Tenant.unscoped.find(params[:id])
        tenant.update!(status: 'inactive')
        
        render_success(message: 'Tenant deactivated successfully')
      end

      # GET /api/v1/tenants/:id/stats
      def stats
        tenant = Tenant.unscoped.find(params[:id])
        
        render_success(tenant_stats(tenant))
      end

      private

      def tenant_params
        params.require(:tenant).permit(
          :slug, :name, :subdomain, :custom_domain, :status,
          :region, :country_code, :timezone, :currency,
          :max_drivers, :max_riders, :max_rides_per_month,
          :business_name, :business_email, :support_phone, :support_email,
          :plan_type, :subscription_starts_at, :subscription_ends_at,
          settings: {},
          pricing_config: {},
          branding: {},
          features: {}
        )
      end

      def require_super_admin!
        unless current_user&.super_admin?
          render_error('Super admin access required', status: :forbidden)
        end
      end

      def tenant_stats(tenant)
        service = TenantService.new(tenant)
        
        {
          total_drivers: service.total_drivers,
          active_drivers: service.active_drivers,
          total_riders: service.total_riders,
          total_rides: service.total_rides,
          rides_today: service.rides_today,
          revenue_today: service.revenue_today,
          revenue_this_month: service.revenue_this_month,
          subscription_status: {
            active: service.subscription_active?,
            expiring_soon: service.subscription_expiring_soon?,
            days_remaining: service.days_until_expiration
          },
          quota_status: {
            drivers: {
              current: service.total_drivers,
              limit: tenant.max_drivers || 'unlimited',
              usage_percentage: tenant.max_drivers ? (service.total_drivers.to_f / tenant.max_drivers * 100).round(1) : 0
            },
            riders: {
              current: service.total_riders,
              limit: tenant.max_riders || 'unlimited',
              usage_percentage: tenant.max_riders ? (service.total_riders.to_f / tenant.max_riders * 100).round(1) : 0
            },
            rides: {
              current_month: service.rides_today,
              limit: tenant.max_rides_per_month || 'unlimited',
              usage_percentage: tenant.max_rides_per_month ? (service.rides_today.to_f / tenant.max_rides_per_month * 100).round(1) : 0
            }
          }
        }
      end
    end
  end
end

