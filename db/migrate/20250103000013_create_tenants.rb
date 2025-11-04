class CreateTenants < ActiveRecord::Migration[7.1]
  def change
    create_table :tenants, id: :uuid do |t|
      # Basic Information
      t.string :slug, null: false
      t.string :name, null: false
      t.string :subdomain
      t.string :custom_domain
      t.string :status, default: 'active', null: false

      # Regional Information
      t.string :region
      t.string :country_code, limit: 3
      t.string :timezone, default: 'UTC'
      t.string :currency, limit: 3, default: 'USD'

      # Configuration (JSONB for flexibility)
      t.jsonb :settings, default: {}
      t.jsonb :pricing_config, default: {}
      t.jsonb :branding, default: {}
      t.jsonb :features, default: {}

      # Limits and Quotas
      t.integer :max_drivers
      t.integer :max_riders
      t.integer :max_rides_per_month

      # Business Information
      t.string :business_name
      t.string :business_email
      t.string :support_phone
      t.string :support_email

      # Subscription
      t.string :plan_type
      t.datetime :subscription_starts_at
      t.datetime :subscription_ends_at

      t.timestamps
      t.datetime :deleted_at
    end

    add_index :tenants, :slug, unique: true
    add_index :tenants, :subdomain, unique: true, where: "subdomain IS NOT NULL"
    add_index :tenants, :custom_domain, unique: true, where: "custom_domain IS NOT NULL"
    add_index :tenants, :status
    add_index :tenants, :region
    add_index :tenants, :country_code
    add_index :tenants, :deleted_at
  end
end

