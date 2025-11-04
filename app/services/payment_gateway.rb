# Payment Gateway Orchestrator
# Routes payment processing to appropriate PSP adapter
#
# Usage:
#   PaymentGateway.charge(payment)
#   PaymentGateway.refund(payment)
#
class PaymentGateway
  class Error < StandardError; end
  class NetworkError < Error; end
  class InvalidRequestError < Error; end
  class CardDeclinedError < Error; end
  
  ADAPTERS = {
    'stripe' => 'PaymentGateway::StripeAdapter',
    'paypal' => 'PaymentGateway::PaypalAdapter',
    'braintree' => 'PaymentGateway::BraintreeAdapter'
  }.freeze
  
  DEFAULT_PROVIDER = 'stripe'.freeze
  
  # Charge a payment
  # @param payment [Payment] Payment record to process
  # @return [Boolean] true if successful, false otherwise
  def self.charge(payment)
    provider = determine_provider(payment)
    adapter = load_adapter(provider)
    
    Rails.logger.info("Processing payment #{payment.id} via #{provider}")
    
    adapter.charge(payment)
  rescue NetworkError => e
    Rails.logger.error("Payment gateway network error: #{e.message}")
    raise # Let Sidekiq retry
  rescue Error => e
    Rails.logger.error("Payment gateway error: #{e.message}")
    false
  end
  
  # Refund a payment
  # @param payment [Payment] Payment record to refund
  # @return [Boolean] true if successful, false otherwise
  def self.refund(payment)
    provider = payment.payment_provider || DEFAULT_PROVIDER
    adapter = load_adapter(provider)
    
    Rails.logger.info("Refunding payment #{payment.id} via #{provider}")
    
    adapter.refund(payment)
  rescue Error => e
    Rails.logger.error("Payment refund error: #{e.message}")
    false
  end
  
  # Get payment status from PSP
  # @param payment [Payment] Payment record to check
  # @return [Hash] Status information from PSP
  def self.get_status(payment)
    provider = payment.payment_provider || DEFAULT_PROVIDER
    adapter = load_adapter(provider)
    
    adapter.get_status(payment)
  rescue Error => e
    Rails.logger.error("Payment status check error: #{e.message}")
    nil
  end
  
  private
  
  def self.determine_provider(payment)
    # Priority:
    # 1. Rider's preferred provider
    # 2. Tenant's default provider
    # 3. System default
    payment.rider.preferred_payment_provider ||
      payment.tenant&.default_payment_provider ||
      DEFAULT_PROVIDER
  end
  
  def self.load_adapter(provider)
    adapter_class_name = ADAPTERS[provider]
    
    raise Error, "Unsupported payment provider: #{provider}" unless adapter_class_name
    
    adapter_class_name.constantize
  rescue NameError => e
    raise Error, "Payment adapter not found: #{adapter_class_name}"
  end
end

