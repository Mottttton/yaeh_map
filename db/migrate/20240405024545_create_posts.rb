class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.integer :region, null: false
      t.integer :prefecture
      t.text :description, null: false
      t.integer :genre, null: false
      t.string :place_id, null: false
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
