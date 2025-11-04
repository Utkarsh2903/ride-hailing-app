module Api
  module V1
    class PaymentsController < BaseController
      # POST /api/v1/payments
      def create
        ride = Ride.find(params[:ride_id])
        authorize ride, policy_class: PaymentPolicy

        # Check for existing payment (idempotency)
        existing_payment = Payment.find_by(ride: ride)
        if existing_payment
          return render_success(
            payment: PaymentSerializer.new(existing_payment).serializable_hash[:data][:attributes],
            created: false
          )
        end

        # Create payment
        payment = Payment.create!(
          ride: ride,
          rider: ride.rider,
          driver: ride.driver,
          amount: ride.trip.total_fare,
          payment_method: params[:payment_method] || ride.payment_method,
          idempotency_key: idempotency_key
        )

        # Process asynchronously
        PaymentProcessingJob.perform_later(payment.id)

        render_success(
          payment: PaymentSerializer.new(payment).serializable_hash[:data][:attributes],
          status: :created
        )
      end

      # GET /api/v1/payments/:id
      def show
        payment = Payment.find(params[:id])
        authorize payment

        render_success(payment: PaymentSerializer.new(payment).serializable_hash[:data][:attributes])
      end

      # GET /api/v1/payments
      def index
        payments = policy_scope(Payment)
                     .includes(:ride, :rider, :driver)
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(params[:per_page] || 20)

        render_success(
          payments: payments.map { |p| PaymentSerializer.new(p).serializable_hash[:data][:attributes] },
          meta: pagination_meta(payments)
        )
      end

      # POST /api/v1/payments/:id/retry
      def retry_payment
        payment = Payment.find(params[:id])
        authorize payment, :retry_payment?

        PaymentProcessingJob.perform_later(payment.id)

        render_success(
          payment: PaymentSerializer.new(payment).serializable_hash[:data][:attributes],
          message: 'Payment retry initiated'
        )
      end

      # POST /api/v1/payments/:id/refund
      def refund
        payment = Payment.find(params[:id])
        authorize payment

        raise BusinessLogicError.new('Only completed payments can be refunded') unless payment.completed?

        payment.refund_payment!

        render_success(
          payment: PaymentSerializer.new(payment).serializable_hash[:data][:attributes],
          message: 'Payment refunded successfully'
        )
      end

      private

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end
