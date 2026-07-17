# Post を JSON へ変換する（gem を使わないシンプルなシリアライザ）
module PostSerializer
  module_function

  def card(post, current_account:)
    {
      id: post.id,
      title: post.title,
      description: post.description,
      genre: post.genre,
      region: post.region,
      prefecture: post.prefecture,
      place: post.place,
      latitude: post.latitude,
      longitude: post.longitude,
      location_accuracy: post.location_accuracy,
      created_at: post.created_at.iso8601,
      account: AccountSerializer.basic(post.account),
      photos: post.photos.map { |photo| photo_json(photo) },
      favorites_count: post.favorites.size,
      favorited: post.favorites.any? { |favorite| favorite.account_id == current_account.id }
    }
  end

  def photo_json(photo)
    # コントローラ外でも動くよう only_path を明示してプロキシ配信のパスを生成する
    helpers = Rails.application.routes.url_helpers
    {
      # 編集時に「残す写真」を指定するための識別子（photo_signed_ids として送り返す）
      signed_id: photo.blob.signed_id,
      url: helpers.rails_storage_proxy_path(photo, only_path: true),
      thumb_url: helpers.rails_storage_proxy_path(photo.variant(resize_to_limit: [400, 300]), only_path: true)
    }
  end
end
