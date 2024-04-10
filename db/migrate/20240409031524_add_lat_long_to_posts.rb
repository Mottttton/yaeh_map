class AddLatLongToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :latitude, :float, null: false
    add_column :posts, :longitude, :float, null: false
    rename_column :posts, :place_id, :place
  end
end
