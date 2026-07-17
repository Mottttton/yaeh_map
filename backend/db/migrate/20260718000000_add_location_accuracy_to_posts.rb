class AddLocationAccuracyToPosts < ActiveRecord::Migration[8.0]
  def change
    # default: 0 (exact) により既存投稿はすべて「正確」になる
    add_column :posts, :location_accuracy, :integer, null: false, default: 0
    # おおまか/位置なしの投稿では座標・place を保存しないため NOT NULL を解除する
    change_column_null :posts, :latitude, true
    change_column_null :posts, :longitude, true
    change_column_null :posts, :place, true
  end
end
