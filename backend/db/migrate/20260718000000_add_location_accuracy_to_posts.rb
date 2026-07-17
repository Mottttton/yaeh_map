class AddLocationAccuracyToPosts < ActiveRecord::Migration[8.0]
  def change
    # default: 0 (exact) で追加して既存投稿を「正確」にバックフィルした後、
    # 新規レコードの未指定デフォルトは安全側の 1 (approximate) にする
    add_column :posts, :location_accuracy, :integer, null: false, default: 0
    change_column_default :posts, :location_accuracy, from: 0, to: 1
    # おおまか/位置なしの投稿では座標・place を保存しないため NOT NULL を解除する
    change_column_null :posts, :latitude, true
    change_column_null :posts, :longitude, true
    change_column_null :posts, :place, true
  end
end
