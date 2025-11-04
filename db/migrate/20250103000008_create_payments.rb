class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :ride, type: :uuid, foreign_key: true, null: false
      t.references :rider, type: :uuid, foreign_key: true, null: false
      t.references :driver, type: :uuid, foreign_key: true, null: false
      
      t.string :status, null: false, default: 'pending'
      t.string :payment_method, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false, default: 'USD'
      
      # External PSP integration
      t.string :transaction_id
      t.string :payment_provider
      t.string :payment_provider_status
      t.jsonb :payment_provider_response, default: {}
      
      # Split details
      t.decimal :driver_amount, precision: 10, scale: 2
      t.decimal :platform_fee, precision: 10, scale: 2
      t.decimal :tax_amount, precision: 10, scale: 2
      
      # Timing
      t.datetime :initiated_at
      t.datetime :completed_at
      t.datetime :failed_at
      t.string :failure_reason
      t.integer :retry_count, default: 0
      
      # Idempotency
      t.string :idempotency_key, null: false
      
      t.jsonb :metadata, default: {}
      
      t.timestamps
      
      t.index :ride_id
      t.index :rider_id
      t.index :driver_id
      t.index :status
      t.index :transaction_id, unique: true, where: "transaction_id IS NOT NULL"
      t.index :idempotency_key, unique: true
      t.index :created_at
      t.index [:status, :created_at]
    end
  end
end

