unless Account.find_by(name: "yaehmap")
  Account.create!(name: "yaehmap", email: "yaehmap@sample.com", nickname: "ヤエー(サンプルアカウント)", password: "password", region: "関東")
end
unless Account.find_by(name: "honda")
  Account.create!(name: "honda", email: "honda@sample.com", nickname: "ホンダ(サンプルアカウント)", password: "password", region: "関東")
end
unless Account.find_by(name: "yamaha")
  Account.create!(name: "yamaha", email: "yamaha@sample.com", nickname: "ヤマハ(サンプルアカウント)", password: "password", region: "東海")
end
unless Account.find_by(name: "suzuki")
  Account.create!(name: "suzuki", email: "suzuki@sample.com", nickname: "スズキ(サンプルアカウント)", password: "password", region: "東海")
end
unless Account.find_by(name: "kawasaki")
  Account.create!(name: "kawasaki", email: "kawasaki@sample.com", nickname: "カワサキ(サンプルアカウント)", password: "password", region: "近畿")
end

yaemap_account = Account.find_by(name: "yaehmap")
unless Post.find_by(title: "おすすめの道の駅 針テラス")
  Post.create!(title: "おすすめの道の駅 針テラス", description: "いつもバイクで賑わっている道の駅。周りの道も快走路で走ってて気持ちが良いです！", region: "近畿", prefecture: "奈良", genre: "オススメ", place: "ChIJEZJqyp9LAWARYVfmME2nfN4", latitude: 34.6102067, longitude: 135.9623548, account_id: yaemap_account.id)
end
unless Post.find_by(title: "おすすめの道の駅 塩見坂")
  Post.create!(title: "おすすめの道の駅 塩見坂", description: "太平洋を一望できる道の駅。ここからもう少し東に行くとバイクの街、浜松です。冬場は西風が強いので注意。", region: "東海", prefecture: "静岡", genre: "オススメ", place: "ChIJ6YCOSncqG2ARJ1Oh1f1L0M8", latitude: 34.677237925440295, longitude: 137.49841332435608, account_id: yaemap_account.id)
end
unless Post.find_by(title: "おすすめの道の駅 美山ふれあい広場")
  Post.create!(title: "おすすめの道の駅 美山ふれあい広場", description: "のんびりした雰囲気の道の駅。周りは快走路で走りやすいです。天橋立や丹波などの中継地点として休憩場所にピッタリ。ジェラートやソフトクリームは絶品！", region: "近畿", prefecture: "京都", genre: "オススメ", place: "ChIJ06UNGTk1AGARo7IkwFDsPHw", latitude: 35.2767452, longitude: 135.5879344, account_id: yaemap_account.id)
end
unless Post.find_by(title: "車の合流注意")
  Post.create!(title: "車の合流注意", description: "御堂筋は全体的に合流車線の余裕が少ないので注意。特にここは上から降ってくる車がフェンスで見えないので急に飛び出してくるように見えます。", region: "近畿", prefecture: "大阪", genre: "注意", place: "GhIJlpxuNNtlQUAR8UQQ5-HvYEA", latitude: 34.7957520894292, longitude: 135.4963259809722, account_id: yaemap_account.id)
end
unless Post.find_by(title: "無料駐輪場")
  Post.create!(title: "無料駐輪場", description: "ビックカメラの隣に無料の駐輪場あります。大型車も停められます！", region: "東海", prefecture: "静岡", genre: "駐輪場", place: "ChIJyflj6HneGmARKsN0ImaLbS0", latitude: 34.703184958766606, longitude: 137.73334167489165, account_id: yaemap_account.id)
end
