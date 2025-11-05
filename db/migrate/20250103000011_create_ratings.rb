class CreateRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :ratings, id: :uuid do |t|
      t.references :ride, type: :uuid, foreign_key: true, null: false
      t.references :rater, type: :uuid, polymorphic: true, null: false
      t.references :rated, type: :uuid, polymorphic: true, null: false
      t.integer :score, null: false
      t.text :comment
      t.jsonb :tags, default: []
      
      t.timestamps
      
      t.index :ride_id, unique: true, name: "idx_ratings_ride_unique"
      t.index [:rater_type, :rater_id], name: "idx_ratings_rater"
      t.index [:rated_type, :rated_id], name: "idx_ratings_rated"
      t.index :score, name: "idx_ratings_score"
      t.index :created_at, name: "idx_ratings_created_at"
    end
    
    add_check_constraint :ratings, "score >= 1 AND score <= 5", name: "valid_score"
  end
end

