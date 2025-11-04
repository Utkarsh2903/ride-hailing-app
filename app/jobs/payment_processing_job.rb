class PaymentProcessingJob < ApplicationJob
  queue_as :critical

  # Retry strategy for payment failures
  retry_on StandardError, wait: :exponentially_longer, attempts: 5

  def perform(payment_id)
    payment = Payment.find(payment_id)
    
    # Skip if already processed
    return if payment.completed?

    # Process the payment
    success = payment.process_payment!

    if success
      # Notify both parties
      notify_payment_success(payment)
    else
      # Notify payment failure
      notify_payment_failure(payment)
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Payment processing failed - Payment not found: #{e.message}"
  end

  private

  def notify_payment_success(payment)
    # Notify rider
    NotificationService.call(
      user: payment.rider.user,
      type: 'payment_completed',
      title: 'Payment Successful',
      body: "Payment of $#{payment.amount} was successful",
      data: { payment_id: payment.id, ride_id: payment.ride_id }
    )

    # Notify driver
    NotificationService.call(
      user: payment.driver.user,
      type: 'payment_received',
      title: 'Payment Received',
      body: "You earned $#{payment.driver_amount}",
      data: { payment_id: payment.id, ride_id: payment.ride_id }
    )
  end

  def notify_payment_failure(payment)
    NotificationService.call(
      user: payment.rider.user,
      type: 'payment_failed',
      title: 'Payment Failed',
      body: 'There was an issue processing your payment. Please check your payment method.',
      data: { payment_id: payment.id, ride_id: payment.ride_id }
    )
  end
end

