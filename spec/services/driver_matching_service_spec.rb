require 'rails_helper'

RSpec.describe DriverMatchingService do
  describe '#call' do
    let(:rider) { create(:rider) }
    let(:ride) { create(:ride, rider: rider, status: 'requested') }
    
    context 'when drivers are available nearby' do
      let!(:driver1) do
        driver = create(:driver, status: 'online', rating: 4.8, acceptance_rate: 95.0)
        create(:driver_location,
          driver: driver,
          latitude: ride.pickup_latitude + 0.01,
          longitude: ride.pickup_longitude + 0.01
        )
        driver
      end

      let!(:driver2) do
        driver = create(:driver, status: 'online', rating: 4.5, acceptance_rate: 90.0)
        create(:driver_location,
          driver: driver,
          latitude: ride.pickup_latitude + 0.02,
          longitude: ride.pickup_longitude + 0.02
        )
        driver
      end

      before do
        # Mock Redis cache
        allow(DriverLocationCache).to receive(:nearby_drivers)
          .and_return([
            { driver_id: driver1.id, distance: 1.1, latitude: driver1.current_location.latitude, longitude: driver1.current_location.longitude },
            { driver_id: driver2.id, distance: 2.2, latitude: driver2.current_location.latitude, longitude: driver2.current_location.longitude }
          ])
      end

      it 'successfully finds and notifies drivers' do
        result = described_class.call(ride)
        
        expect(result.success?).to be true
        expect(result.data[:drivers_found]).to eq(2)
        expect(result.data[:offers_sent]).to be > 0
      end

      it 'changes ride status to searching' do
        expect { described_class.call(ride) }
          .to change { ride.reload.status }.to('searching')
      end

      it 'creates driver assignments' do
        expect { described_class.call(ride) }
          .to change { DriverAssignment.count }.by_at_least(1)
      end

      it 'scores drivers correctly' do
        result = described_class.call(ride)
        assignments = result.data[:assignments]
        
        # Higher rated driver closer should be offered first
        expect(assignments.first.driver_id).to eq(driver1.id)
      end
    end

    context 'when no drivers are available' do
      before do
        allow(DriverLocationCache).to receive(:nearby_drivers).and_return([])
      end

      it 'returns failure' do
        result = described_class.call(ride)
        
        expect(result.failure?).to be true
        expect(result.error_messages).to include('No drivers available nearby')
      end
    end

    context 'when ride is not in correct state' do
      let(:completed_ride) { create(:ride, status: 'completed') }

      it 'returns failure' do
        result = described_class.call(completed_ride)
        
        expect(result.failure?).to be true
      end
    end
  end

  describe 'performance' do
    let(:ride) { create(:ride, status: 'requested') }
    let!(:drivers) do
      10.times.map do
        driver = create(:driver, status: 'online')
        create(:driver_location, driver: driver)
        driver
      end
    end

    before do
      driver_locations = drivers.map do |driver|
        { driver_id: driver.id, distance: 2.0, latitude: 37.7749, longitude: -122.4194 }
      end
      allow(DriverLocationCache).to receive(:nearby_drivers).and_return(driver_locations)
    end

    it 'completes matching within 1 second' do
      expect {
        described_class.call(ride)
      }.to perform_under(1).sec
    end
  end
end

