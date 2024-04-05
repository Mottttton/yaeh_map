class Region < ActiveRecord::Base
  enum region: %i(北海道 東北 関東 北陸 東海 近畿 中国 四国 九州 沖縄)
end
