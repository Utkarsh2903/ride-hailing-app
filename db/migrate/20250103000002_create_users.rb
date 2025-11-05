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
      
      t.index :email, unique: true, name: "idx_users_email_unique"
      t.index :phone, unique: true, name: "idx_users_phone_unique"
      t.index :role, name: "idx_users_role"
      t.index :status, name: "idx_users_status"
      t.index :created_at, name: "idx_users_created_at"
    end
  end
end

