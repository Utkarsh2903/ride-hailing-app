# Base adapter for payment service providers
# All PSP adapters should inherit from this class
#
module PaymentGateway
  class BaseAdapter
    # Charge a payment
    # @param payment [Payment] Payment record to process
    # @return [Boolean] true if successful, false otherwise
    def self.charge(payment)
      raise NotImplementedError, "#{name} must implement #charge"
    end
    
    # Refund a payment
    # @param payment [Payment] Payment record to refund
    # @return [Boolean] true if successful, false otherwise
    def self.refund(payment)
      raise NotImplementedError, "#{name} must implement #refund"
    end
    
    # Get payment status from PSP
    # @param payment [Payment] Payment record to check
    # @return [Hash] Status information from PSP
    def self.get_status(payment)
      raise NotImplementedError, "#{name} must implement #get_status"
    end
    
    # Create a customer in PSP
    # @param rider [Rider] Rider to create customer for
    # @return [String] PSP customer ID
    def self.create_customer(rider)
      raise NotImplementedError, "#{name} must implement #create_customer"
    end
    
    # Add payment method to customer
    # @param rider [Rider] Rider to add payment method for
    # @param payment_method_token [String] Token from PSP client-side
    # @return [String] PSP payment method ID
    def self.add_payment_method(rider, payment_method_token)
      raise NotImplementedError, "#{name} must implement #add_payment_method"
    end
    
    protected
    
    # Convert amount to PSP format (usually cents)
    def self.to_cents(amount)
      (amount * 100).to_i
    end
    
    # Convert amount from PSP format (cents) to dollars
    def self.from_cents(cents)
      (cents / 100.0).round(2)
    end
    
    # Update payment with PSP response
    def self.update_payment_success(payment, transaction_id, provider_status, provider_response)
      payment.update!(
        transaction_id: transaction_id,
        payment_provider_status: provider_status,
        payment_provider_response: provider_response
      )
    end
    
    # Update payment with PSP error
    def self.update_payment_failure(payment, error_message, provider_response = {})
      payment.update!(
        failure_reason: error_message,
        payment_provider_response: provider_response
      )
    end
  end
end

