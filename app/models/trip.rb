# == Schema Information
#
# Table name: trips
#
#  id                :uuid             not null, primary key
#  ride_id           :uuid             not null
#  status            :string           default("in_progress"), not null
#  started_at        :datetime
#  ended_at          :datetime
#  actual_distance   :decimal(10, 2)
#  actual_duration   :integer
#  base_fare         :decimal(10, 2)
#  distance_fare     :decimal(10, 2)
#  time_fare         :decimal(10, 2)
#  surge_amount      :decimal(10, 2)   default(0.0)
#  total_fare        :decimal(10, 2)
#  route_coordinates :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Trip < ApplicationRecord
  include AASM
  include TenantScoped

  # Associations
  belongs_to :ride

  # Validations
  validates :status, presence: true

  # Callbacks
  before_create :set_started_at
  before_update :calculate_duration, if: :ended_at_changed?

  # State Machine
  aasm column: :status do
    state :in_progress, initial: true
    state :completed
    state :cancelled

    event :complete do
      transitions from: :in_progress, to: :completed
      after do
        update_column(:ended_at, Time.current)
        calculate_fare!
      end
    end

    event :cancel do
      transitions from: :in_progress, to: :cancelled
    end
  end

  # Scopes
  scope :active, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def calculate_fare!
    return if completed?

    tier_sym = ride.tier.to_sym
    surge = ride.surge_multiplier

    # Base fare by tier
    base_fares = { economy: 2.50, standard: 3.50, premium: 5.00, suv: 6.00, luxury: 10.00 }
    per_km_rates = { economy: 1.00, standard: 1.50, premium: 2.50, suv: 3.00, luxury: 5.00 }
    per_min_rates = { economy: 0.15, standard: 0.20, premium: 0.30, suv: 0.35, luxury: 0.50 }

    self.base_fare = base_fares[tier_sym] || 3.50
    self.distance_fare = (actual_distance || 0) * (per_km_rates[tier_sym] || 1.50)
    self.time_fare = (actual_duration || 0) / 60.0 * (per_min_rates[tier_sym] || 0.20)
    
    # Calculate surge amount
    subtotal = base_fare + distance_fare + time_fare
    self.surge_amount = subtotal * (surge - 1.0)
    
    # Calculate total (simplified - only base components + surge)
    self.total_fare = subtotal + surge_amount

    save!
  end

  def duration_minutes
    return nil unless started_at && ended_at
    ((ended_at - started_at) / 60.0).round(2)
  end

  private

  def set_started_at
    self.started_at ||= Time.current
  end

  def calculate_duration
    self.actual_duration = ((ended_at - started_at) / 60.0).round(0) if started_at && ended_at
  end
end

