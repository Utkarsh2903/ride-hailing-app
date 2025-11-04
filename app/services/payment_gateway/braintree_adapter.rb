# Braintree Payment Service Provider Adapter
#
# Setup:
#   1. Add to Gemfile: gem 'braintree', '~> 4.0'
#   2. Run: bundle install
#   3. Add credentials: rails credentials:edit
#      braintree:
#        merchant_id: ...
#        public_key: ...
#        private_key: ...
#        environment: sandbox  # or 'production'
#
# TODO: Uncomment and implement when Braintree gem is installed
#
module PaymentGateway
  class BraintreeAdapter < BaseAdapter
    # Charge a payment via Braintree
    def self.charge(payment)
      # TODO: Implement Braintree charge
      
      # Stubbed implementation
      Rails.logger.info("[BRAINTREE STUB] Charging payment #{payment.id} for $#{payment.amount}")
      
      payment.update!(
        transaction_id: "braintree_txn_#{SecureRandom.hex(12)}",
        payment_provider: 'braintree',
        payment_provider_status: 'authorized',
        payment_provider_response: { stub: true, amount: payment.amount }
      )
      
      payment.complete!
      true
      
    rescue => e
      Rails.logger.error("[BRAINTREE STUB ERROR] #{e.message}")
      update_payment_failure(payment, e.message)
      payment.fail!
      false
    end
    
    # Refund a payment via Braintree
    def self.refund(payment)
      # TODO: Implement Braintree refund
      
      Rails.logger.info("[BRAINTREE STUB] Refunding payment #{payment.id}")
      
      payment.update!(payment_provider_status: 'refunded')
      payment.refund!
      true
      
    rescue => e
      Rails.logger.error("[BRAINTREE STUB ERROR] Refund failed: #{e.message}")
      false
    end
    
    # Get payment status from Braintree
    def self.get_status(payment)
      # TODO: Implement status check
      
      { status: 'authorized', stub: true }
    end
    
    # Create Braintree customer
    def self.create_customer(rider)
      # TODO: Implement customer creation
      
      customer_id = "braintree_cus_#{SecureRandom.hex(12)}"
      rider.update!(braintree_customer_id: customer_id)
      customer_id
    end
    
    # Add payment method to Braintree customer
    def self.add_payment_method(rider, payment_method_token)
      # TODO: Implement payment method creation
      
      rider.update!(braintree_payment_method_token: payment_method_token)
      payment_method_token
    end
  end
end

