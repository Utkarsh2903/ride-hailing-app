# Service for calculating ride fares
# Implements Strategy Pattern for different fare calculation methods
class FareCalculationService < ApplicationService
  # Base fares by tier (in USD)
  BASE_FARES = {
    'economy' => 2.50,
    'standard' => 3.50,
    'premium' => 5.00,
    'suv' => 6.00,
    'luxury' => 10.00
  }.freeze

  # Per kilometer rates by tier
  PER_KM_RATES = {
    'economy' => 1.00,
    'standard' => 1.50,
    'premium' => 2.50,
    'suv' => 3.00,
    'luxury' => 5.00
  }.freeze

  # Per minute rates by tier
  PER_MINUTE_RATES = {
    'economy' => 0.15,
    'standard' => 0.20,
    'premium' => 0.30,
    'suv' => 0.35,
    'luxury' => 0.50
  }.freeze

  # Constants
  SERVICE_FEE_PERCENTAGE = 0.10
  TAX_PERCENTAGE = 0.05
  FREE_WAITING_MINUTES = 3
  WAITING_CHARGE_PER_MINUTE = 0.50
  MINIMUM_FARE = 5.00

  def initialize(ride:, actual_distance: nil, actual_duration: nil, waiting_time: 0, tip_amount: 0)
    @ride = ride
    @tier = ride.tier
    @surge_multiplier = ride.surge_multiplier
    @actual_distance = actual_distance || ride.estimated_distance
    @actual_duration = actual_duration || ride.estimated_duration
    @waiting_time = waiting_time
    @tip_amount = tip_amount
  end

  def call
    fare_breakdown = calculate_fare_breakdown

    success(fare_breakdown)
  rescue StandardError => e
    failure("Fare calculation failed: #{e.message}")
  end

  private

  def calculate_fare_breakdown
    # Base components
    base_fare = BASE_FARES[@tier] || BASE_FARES['standard']
    distance_fare = (@actual_distance || 0) * (PER_KM_RATES[@tier] || PER_KM_RATES['standard'])
    time_fare = ((@actual_duration || 0) / 60.0) * (PER_MINUTE_RATES[@tier] || PER_MINUTE_RATES['standard'])

    # Subtotal before surge
    subtotal = base_fare + distance_fare + time_fare

    # Surge pricing
    surge_amount = subtotal * (@surge_multiplier - 1.0)

    # Waiting charges
    waiting_charge = calculate_waiting_charge

    # Service fee
    service_fee = subtotal * SERVICE_FEE_PERCENTAGE

    # Tax calculation
    taxable_amount = subtotal + surge_amount + waiting_charge
    tax_amount = taxable_amount * TAX_PERCENTAGE

    # Total before tip
    total_before_tip = subtotal + surge_amount + waiting_charge + service_fee + tax_amount

    # Apply minimum fare
    if total_before_tip < MINIMUM_FARE
      adjustment = MINIMUM_FARE - total_before_tip
      total_before_tip = MINIMUM_FARE
    else
      adjustment = 0
    end

    # Add tip
    total_fare = total_before_tip + @tip_amount

    {
      base_fare: base_fare.round(2),
      distance_fare: distance_fare.round(2),
      time_fare: time_fare.round(2),
      subtotal: subtotal.round(2),
      surge_multiplier: @surge_multiplier,
      surge_amount: surge_amount.round(2),
      waiting_charge: waiting_charge.round(2),
      service_fee: service_fee.round(2),
      tax_amount: tax_amount.round(2),
      minimum_fare_adjustment: adjustment.round(2),
      tip_amount: @tip_amount.round(2),
      total_fare: total_fare.round(2),
      currency: 'USD',
      breakdown_text: generate_breakdown_text(
        base_fare: base_fare,
        distance_fare: distance_fare,
        time_fare: time_fare,
        surge_amount: surge_amount,
        waiting_charge: waiting_charge,
        service_fee: service_fee,
        tax_amount: tax_amount,
        tip_amount: @tip_amount,
        total_fare: total_fare
      )
    }
  end

  def calculate_waiting_charge
    return 0.0 if @waiting_time <= FREE_WAITING_MINUTES

    billable_waiting = @waiting_time - FREE_WAITING_MINUTES
    billable_waiting * WAITING_CHARGE_PER_MINUTE
  end

  def generate_breakdown_text(amounts)
    lines = []
    lines << "Base fare: $#{amounts[:base_fare].round(2)}"
    lines << "Distance (#{@actual_distance&.round(2)}km): $#{amounts[:distance_fare].round(2)}"
    lines << "Time (#{@actual_duration}min): $#{amounts[:time_fare].round(2)}"
    
    if amounts[:surge_amount] > 0
      lines << "Surge (#{@surge_multiplier}x): $#{amounts[:surge_amount].round(2)}"
    end
    
    if amounts[:waiting_charge] > 0
      lines << "Waiting time: $#{amounts[:waiting_charge].round(2)}"
    end
    
    lines << "Service fee: $#{amounts[:service_fee].round(2)}"
    lines << "Tax: $#{amounts[:tax_amount].round(2)}"
    
    if amounts[:tip_amount] > 0
      lines << "Tip: $#{amounts[:tip_amount].round(2)}"
    end
    
    lines << "---"
    lines << "Total: $#{amounts[:total_fare].round(2)}"
    
    lines.join("\n")
  end

  # Class method for estimating fare before ride
  def self.estimate_fare(ride)
    new(ride: ride).call
  end

  # Class method for calculating final fare
  def self.calculate_final_fare(trip)
    ride = trip.ride
    new(
      ride: ride,
      actual_distance: trip.actual_distance,
      actual_duration: trip.actual_duration,
      waiting_time: trip.waiting_time,
      tip_amount: trip.tip_amount
    ).call
  end
end

