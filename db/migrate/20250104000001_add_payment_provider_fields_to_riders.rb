class AddPaymentProviderFieldsToRiders < ActiveRecord::Migration[7.1]
  def change
    add_column :riders, :stripe_customer_id, :string
    add_column :riders, :stripe_payment_method_id, :string
    add_column :riders, :paypal_customer_id, :string
    add_column :riders, :braintree_customer_id, :string
    add_column :riders, :braintree_payment_method_token, :string
    add_column :riders, :preferred_payment_provider, :string, default: 'stripe'
    
    # Indexes for fast lookups
    add_index :riders, :stripe_customer_id, unique: true, where: "stripe_customer_id IS NOT NULL"
    add_index :riders, :paypal_customer_id, unique: true, where: "paypal_customer_id IS NOT NULL"
    add_index :riders, :braintree_customer_id, unique: true, where: "braintree_customer_id IS NOT NULL"
  end
end

