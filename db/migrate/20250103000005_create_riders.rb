class CreateRiders < ActiveRecord::Migration[7.1]
  def change
    create_table :riders, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.decimal :rating, precision: 3, scale: 2, default: 5.0
      t.integer :total_trips, default: 0
      t.integer :completed_trips, default: 0
      t.integer :cancelled_trips, default: 0
      t.string :preferred_payment_method, default: 'card'
      t.jsonb :saved_addresses, default: {}
      t.jsonb :metadata, default: {}
      
      t.timestamps
      
      t.index :rating
      t.index :created_at
    end
  end
end

