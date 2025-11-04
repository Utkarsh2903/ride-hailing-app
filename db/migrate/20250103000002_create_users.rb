class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :phone, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :role, null: false, default: 'rider'
      t.string :status, null: false, default: 'active'
      t.jsonb :metadata, default: {}
      
      t.timestamps
      
      t.index :email, unique: true
      t.index :phone, unique: true
      t.index :role
      t.index :status
      t.index :created_at
    end
  end
end

