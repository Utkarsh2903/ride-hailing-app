class AddDefaultPaymentProviderToTenants < ActiveRecord::Migration[7.1]
  def change
    add_column :tenants, :default_payment_provider, :string, default: 'stripe'
  end
end

