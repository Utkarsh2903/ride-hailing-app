module Api
  module V1
    class BaseController < ApplicationController
      include Pundit::Authorization
      include TenantAware
      include Authenticable
      include ErrorHandler
      include JsonapiRenderable

      # Verify user belongs to current tenant
      before_action :verify_tenant_access!, if: -> { current_user.present? }

      # Idempotency key handling
      def idempotency_key
        request.headers['Idempotency-Key'] || SecureRandom.uuid
      end

      # Current tenant helper
      def current_tenant
        Tenant.current
      end

      # Tenant service helper
      def tenant_service
        @tenant_service ||= TenantService.new(current_tenant)
      end
    end
  end
end

