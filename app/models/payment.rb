# == Schema Information
#
# Table name: payments
#
#  id                        :uuid             not null, primary key
#  ride_id                   :uuid             not null
#  rider_id                  :uuid             not null
#  driver_id                 :uuid             not null
#  status                    :string           default("pending"), not null
#  payment_method            :integer          default(0), not null
#  amount                    :decimal(10, 2)   not null
#  currency                  :string           default("USD"), not null
#  transaction_id            :string
#  payment_provider          :string
#  payment_provider_status   :string
#  payment_provider_response :jsonb
#  driver_amount             :decimal(10, 2)
#  platform_fee              :decimal(10, 2)
#  initiated_at              :datetime
#  completed_at              :datetime
#  failed_at                 :datetime
#  failure_reason            :string
#  retry_count               :integer          default(0)
#  idempotency_key           :string           not null
#  tenant_id                 :uuid             not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class Payment < ApplicationRecord
  include AASM
  include TenantScoped

  # Enums
  enum payment_method: { card: 0, cash: 1, wallet: 2 }

  # Associations
  belongs_to :ride
  belongs_to :rider
  belongs_to :driver

  # Validations
  validates :status, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :idempotency_key, presence: true, uniqueness: true
  validates :transaction_id, uniqueness: true, allow_nil: true

  # Callbacks
  before_validation :set_idempotency_key, on: :create
  before_create :calculate_split
  after_create :broadcast_payment_initiated

  # State Machine
  aasm column: :status do
    state :pending, initial: true
    state :processing
    state :completed
    state :failed
    state :refunded
    state :cancelled

    event :process do
      transitions from: :pending, to: :processing
      after do
        update_column(:initiated_at, Time.current)
      end
    end

    event :complete do
      transitions from: :processing, to: :completed
      after do
        update_column(:completed_at, Time.current)
        ride.update_column(:payment_status, 'paid')
      end
    end

    event :fail do
      transitions from: [:pending, :processing], to: :failed
      after do
        update_column(:failed_at, Time.current)
        increment!(:retry_count)
      end
    end

    event :refund do
      transitions from: :completed, to: :refunded
    end

    event :cancel do
      transitions from: [:pending, :processing], to: :cancelled
    end
  end

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rider, ->(rider_id) { where(rider_id: rider_id) }
  scope :by_driver, ->(driver_id) { where(driver_id: driver_id) }

  # Instance methods
  def retriable?
    failed? && retry_count < 3
  end

  def process_payment!
    return false unless may_process?

    process!

    if card?
      process_card_payment
    elsif cash?
      process_cash_payment
    elsif wallet?
      process_wallet_payment
    end
  end

  def refund_payment!
    return false unless may_refund?

    # Call external PSP to refund
    if payment_provider == 'cash'
      # Cash refunds are handled manually
      refund!
      true
    else
      PaymentGateway.refund(self)
    end
  end

  private

  def set_idempotency_key
    self.idempotency_key ||= SecureRandom.uuid
  end

  def calculate_split
    # Platform takes 20% commission
    self.platform_fee = (amount * 0.20).round(2)
    self.driver_amount = (amount - platform_fee).round(2)
  end

  def broadcast_payment_initiated
    # Broadcast to Action Cable channel
    # ActionCable.server.broadcast("rider_#{rider_id}", {
    #   type: 'payment_initiated',
    #   payment: PaymentSerializer.new(self).serializable_hash
    # })
  end

  def process_card_payment
    # Process via external PSP (Stripe, PayPal, Braintree)
    PaymentGateway.charge(self)
  rescue StandardError => e
    Rails.logger.error("Card payment failed: #{e.message}")
    fail!
    false
  end

  def process_cash_payment
    # Cash payments are marked as completed when driver confirms
    self.transaction_id = "cash_#{SecureRandom.hex(12)}"
    self.payment_provider = 'cash'
    complete!
    true
  end

  def process_wallet_payment
    # Process via wallet PSP
    PaymentGateway.charge(self)
  rescue StandardError => e
    Rails.logger.error("Wallet payment failed: #{e.message}")
    fail!
    false
  end
end

