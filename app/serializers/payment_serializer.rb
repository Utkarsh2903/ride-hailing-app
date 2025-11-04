# Serializer for Payment responses
class PaymentSerializer
  include JSONAPI::Serializer

  attributes :status, :amount, :payment_method, :transaction_id

  attribute :timestamps do |payment|
    {
      initiated_at: payment.initiated_at&.iso8601,
      completed_at: payment.completed_at&.iso8601,
      failed_at: payment.failed_at&.iso8601
    }
  end

  attribute :split do |payment|
    {
      platform_fee: payment.platform_fee,
      driver_amount: payment.driver_amount
    }
  end
end

