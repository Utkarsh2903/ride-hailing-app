# == Schema Information
#
# Table name: driver_assignments
#
#  id                 :uuid             not null, primary key
#  ride_id            :uuid             not null
#  driver_id          :uuid             not null
#  status             :string           default("offered"), not null
#  distance_to_pickup :decimal(10, 2)
#  eta_to_pickup      :integer
#  offered_at         :datetime
#  accepted_at        :datetime
#  declined_at        :datetime
#  expired_at         :datetime
#  timeout_at         :datetime
#  decline_reason     :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class DriverAssignment < ApplicationRecord
  include AASM
  include TenantScoped

  # Constants
  OFFER_TIMEOUT = 30.seconds

  # Associations
  belongs_to :ride
  belongs_to :driver

  # Validations
  validates :status, presence: true

  # Callbacks
  before_create :set_offered_at
  before_create :set_timeout_at

  # State Machine
  aasm column: :status do
    state :offered, initial: true
    state :accepted
    state :declined
    state :expired
    state :timeout

    event :accept do
      transitions from: :offered, to: :accepted
      after do
        update_column(:accepted_at, Time.current)
        ride.assign_driver!(driver)
      end
    end

    event :decline do
      transitions from: :offered, to: :declined
      after do
        update_column(:declined_at, Time.current)
      end
    end

    event :expire do
      transitions from: :offered, to: :expired
      after do
        update_column(:expired_at, Time.current)
      end
    end

    event :mark_timeout do
      transitions from: :offered, to: :timeout
      after do
        update_column(:timeout_at, Time.current)
      end
    end
  end

  # Scopes
  scope :pending, -> { where(status: 'offered') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :declined, -> { where(status: 'declined') }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def timed_out?
    offered? && timeout_at.present? && Time.current > timeout_at
  end

  def process_timeout!
    mark_timeout! if timed_out? && may_mark_timeout?
  end

  private

  def set_offered_at
    self.offered_at ||= Time.current
  end

  def set_timeout_at
    self.timeout_at = (offered_at || Time.current) + OFFER_TIMEOUT
  end
end

