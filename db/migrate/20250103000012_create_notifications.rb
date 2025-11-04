class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.string :notification_type, null: false
      t.string :title, null: false
      t.text :body
      t.jsonb :data, default: {}
      t.boolean :read, default: false
      t.datetime :read_at
      t.string :channel
      t.string :status, default: 'pending'
      
      t.timestamps
      
      t.index :user_id
      t.index :notification_type
      t.index :read
      t.index :created_at
      t.index [:user_id, :read, :created_at]
    end
  end
end

