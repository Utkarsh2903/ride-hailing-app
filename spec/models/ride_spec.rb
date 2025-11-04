require 'rails_helper'

RSpec.describe Ride, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:tier) }
    it { should validate_inclusion_of(:tier).in_array(%w[economy standard premium suv luxury]) }
    it { should validate_presence_of(:pickup_latitude) }
    it { should validate_presence_of(:pickup_longitude) }
    it { should validate_numericality_of(:pickup_latitude).is_greater_than_or_equal_to(-90).is_less_than_or_equal_to(90) }
    it { should validate_numericality_of(:pickup_longitude).is_greater_than_or_equal_to(-180).is_less_than_or_equal_to(180) }
    it { should validate_presence_of(:idempotency_key) }
    it { should validate_uniqueness_of(:idempotency_key) }
  end

  describe 'associations' do
    it { should belong_to(:rider) }
    it { should belong_to(:driver).optional }
    it { should have_one(:trip).dependent(:destroy) }
    it { should have_one(:payment).dependent(:destroy) }
    it { should have_many(:driver_assignments).dependent(:destroy) }
  end

  describe 'state machine' do
    let(:ride) { create(:ride, status: 'requested') }

    it 'has initial state of requested' do
      expect(ride.requested?).to be true
    end

    it 'transitions from requested to searching' do
      expect { ride.start_searching! }.to change { ride.status }.from('requested').to('searching')
    end

    it 'transitions from searching to accepted' do
      ride.start_searching!
      expect { ride.accept! }.to change { ride.status }.from('searching').to('accepted')
    end

    it 'sets accepted_at when accepted' do
      ride.accept!
      expect(ride.accepted_at).to be_present
    end
  end

  describe '#distance_between_points' do
    let(:ride) do
      build(:ride,
        pickup_latitude: 37.7749,
        pickup_longitude: -122.4194,
        dropoff_latitude: 37.8044,
        dropoff_longitude: -122.2711
      )
    end

    it 'calculates distance between pickup and dropoff' do
      distance = ride.distance_between_points
      expect(distance).to be > 0
      expect(distance).to be_a(Float)
    end
  end

  describe '#calculate_estimates' do
    let(:ride) do
      build(:ride,
        pickup_latitude: 37.7749,
        pickup_longitude: -122.4194,
        dropoff_latitude: 37.8044,
        dropoff_longitude: -122.2711,
        tier: 'standard',
        surge_multiplier: 1.5
      )
    end

    before { ride.save }

    it 'calculates estimated distance' do
      expect(ride.estimated_distance).to be > 0
    end

    it 'calculates estimated duration' do
      expect(ride.estimated_duration).to be > 0
    end

    it 'calculates estimated fare' do
      expect(ride.estimated_fare).to be > 0
    end

    it 'applies surge multiplier to fare' do
      expect(ride.estimated_fare).to eq((ride.estimated_distance * 1.5 + 3.5) * 1.5)
    end
  end

  describe '#can_be_cancelled?' do
    it 'returns true for requested status' do
      ride = build(:ride, status: 'requested')
      expect(ride.can_be_cancelled?).to be true
    end

    it 'returns false for completed status' do
      ride = build(:ride, status: 'completed')
      expect(ride.can_be_cancelled?).to be false
    end
  end

  describe 'scopes' do
    let!(:active_ride) { create(:ride, status: 'in_progress') }
    let!(:completed_ride) { create(:ride, status: 'completed') }

    describe '.active' do
      it 'returns only active rides' do
        expect(Ride.active).to include(active_ride)
        expect(Ride.active).not_to include(completed_ride)
      end
    end

    describe '.completed' do
      it 'returns only completed rides' do
        expect(Ride.completed).to include(completed_ride)
        expect(Ride.completed).not_to include(active_ride)
      end
    end
  end
end

