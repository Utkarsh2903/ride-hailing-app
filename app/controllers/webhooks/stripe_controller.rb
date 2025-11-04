module Webhooks
  class StripeController < ApplicationController
    # Skip CSRF and authentication for webhooks
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!, if: :defined_method?
    
    # POST /webhooks/stripe
    def create
      payload = request.body.read
      sig_header = request.headers['Stripe-Signature']
      
      # TODO: Verify webhook signature when Stripe is integrated
      # begin
      #   event = Stripe::Webhook.construct_event(
      #     payload,
      #     sig_header,
      #     Rails.application.credentials.dig(:stripe, :webhook_secret)
      #   )
      # rescue Stripe::SignatureVerificationError => e
      #   Rails.logger.error("Stripe webhook signature verification failed: #{e.message}")
      #   return head :bad_request
      # end
      
      # Stubbed: Parse webhook event
      event = JSON.parse(payload, symbolize_names: true)
      
      Rails.logger.info("Stripe webhook received: #{event[:type]}")
      
      case event[:type]
      when 'payment_intent.succeeded'
        handle_payment_success(event[:data][:object])
      when 'payment_intent.payment_failed'
        handle_payment_failure(event[:data][:object])
      when 'charge.refunded'
        handle_refund(event[:data][:object])
      when 'setup_intent.succeeded'
        handle_payment_method_added(event[:data][:object])
      when 'customer.created'
        handle_customer_created(event[:data][:object])
      else
        Rails.logger.info("Unhandled Stripe webhook event: #{event[:type]}")
      end
      
      head :ok
    rescue JSON::ParserError => e
      Rails.logger.error("Invalid Stripe webhook payload: #{e.message}")
      head :bad_request
    rescue StandardError => e
      Rails.logger.error("Stripe webhook processing error: #{e.message}")
      head :internal_server_error
    end
    
    private
    
    def defined_method?
      respond_to?(:authenticate_user!)
    end
    
    def handle_payment_success(payment_intent)
      payment = Payment.find_by(transaction_id: payment_intent[:id])
      return unless payment
      
      Rails.logger.info("Payment #{payment.id} succeeded via Stripe webhook")
      
      payment.update!(
        payment_provider_status: payment_intent[:status],
        payment_provider_response: payment_intent
      )
      
      payment.complete! if payment.may_complete?
    end
    
    def handle_payment_failure(payment_intent)
      payment = Payment.find_by(transaction_id: payment_intent[:id])
      return unless payment
      
      Rails.logger.error("Payment #{payment.id} failed via Stripe webhook")
      
      error_message = payment_intent.dig(:last_payment_error, :message) || 'Payment failed'
      
      payment.update!(
        failure_reason: error_message,
        payment_provider_status: payment_intent[:status],
        payment_provider_response: payment_intent
      )
      
      payment.fail! if payment.may_fail?
    end
    
    def handle_refund(charge)
      payment = Payment.find_by(transaction_id: charge[:payment_intent])
      return unless payment
      
      Rails.logger.info("Payment #{payment.id} refunded via Stripe webhook")
      
      payment.update!(
        payment_provider_status: 'refunded',
        payment_provider_response: charge
      )
      
      payment.refund! if payment.may_refund?
    end
    
    def handle_payment_method_added(setup_intent)
      # Find rider by customer ID
      rider = Rider.find_by(stripe_customer_id: setup_intent[:customer])
      return unless rider
      
      Rails.logger.info("Payment method added for rider #{rider.id} via Stripe webhook")
      
      rider.update!(stripe_payment_method_id: setup_intent[:payment_method])
    end
    
    def handle_customer_created(customer)
      Rails.logger.info("Stripe customer created: #{customer[:id]}")
      # Customer creation is typically handled synchronously, but logged here for completeness
    end
  end
end

