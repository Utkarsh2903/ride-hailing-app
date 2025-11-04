module Webhooks
  class PaypalController < ApplicationController
    # Skip CSRF and authentication for webhooks
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!, if: :defined_method?
    
    # POST /webhooks/paypal
    def create
      payload = request.body.read
      
      # TODO: Verify webhook signature when PayPal is integrated
      # headers = {
      #   'PAYPAL-TRANSMISSION-ID' => request.headers['PAYPAL-TRANSMISSION-ID'],
      #   'PAYPAL-TRANSMISSION-TIME' => request.headers['PAYPAL-TRANSMISSION-TIME'],
      #   'PAYPAL-TRANSMISSION-SIG' => request.headers['PAYPAL-TRANSMISSION-SIG'],
      #   'PAYPAL-CERT-URL' => request.headers['PAYPAL-CERT-URL'],
      #   'PAYPAL-AUTH-ALGO' => request.headers['PAYPAL-AUTH-ALGO']
      # }
      # 
      # verified = PayPal::SDK::Core::API::Webhooks.verify(webhook_id, headers, payload)
      # return head :unauthorized unless verified
      
      # Stubbed: Parse webhook event
      event = JSON.parse(payload, symbolize_names: true)
      
      Rails.logger.info("PayPal webhook received: #{event[:event_type]}")
      
      case event[:event_type]
      when 'PAYMENT.CAPTURE.COMPLETED'
        handle_payment_success(event[:resource])
      when 'PAYMENT.CAPTURE.DENIED', 'PAYMENT.CAPTURE.DECLINED'
        handle_payment_failure(event[:resource])
      when 'PAYMENT.CAPTURE.REFUNDED'
        handle_refund(event[:resource])
      else
        Rails.logger.info("Unhandled PayPal webhook event: #{event[:event_type]}")
      end
      
      head :ok
    rescue JSON::ParserError => e
      Rails.logger.error("Invalid PayPal webhook payload: #{e.message}")
      head :bad_request
    rescue StandardError => e
      Rails.logger.error("PayPal webhook processing error: #{e.message}")
      head :internal_server_error
    end
    
    private
    
    def defined_method?
      respond_to?(:authenticate_user!)
    end
    
    def handle_payment_success(resource)
      payment = Payment.find_by(transaction_id: resource[:id])
      return unless payment
      
      Rails.logger.info("Payment #{payment.id} succeeded via PayPal webhook")
      
      payment.update!(
        payment_provider_status: resource[:status],
        payment_provider_response: resource
      )
      
      payment.complete! if payment.may_complete?
    end
    
    def handle_payment_failure(resource)
      payment = Payment.find_by(transaction_id: resource[:id])
      return unless payment
      
      Rails.logger.error("Payment #{payment.id} failed via PayPal webhook")
      
      payment.update!(
        failure_reason: 'Payment declined or denied',
        payment_provider_status: resource[:status],
        payment_provider_response: resource
      )
      
      payment.fail! if payment.may_fail?
    end
    
    def handle_refund(resource)
      # PayPal sends the capture ID, need to find payment by it
      payment = Payment.find_by(transaction_id: resource[:id])
      return unless payment
      
      Rails.logger.info("Payment #{payment.id} refunded via PayPal webhook")
      
      payment.update!(
        payment_provider_status: 'REFUNDED',
        payment_provider_response: resource
      )
      
      payment.refund! if payment.may_refund?
    end
  end
end

