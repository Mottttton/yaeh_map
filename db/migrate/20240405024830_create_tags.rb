class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.string :name
      t.references :account, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
