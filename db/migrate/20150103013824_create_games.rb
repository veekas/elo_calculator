class CreateGames < ActiveRecord::Migration[4.2]
  def change
    create_table :games do |t|
      t.string :winner_name
      t.string :winner_rating
      t.string :loser_name
      t.string :loser_rating
      t.timestamps
    end
  end
end
