# Account を JSON へ変換する（gem を使わないシンプルなシリアライザ）
module AccountSerializer
  module_function

  # ログイン中の本人情報（セッション API 用）
  def session(account)
    return nil if account.nil?

    profile(account).merge(
      email: account.email,
      admin: account.admin?
    )
  end

  # プロフィール画面用
  def profile(account)
    {
      id: account.id,
      name: account.name,
      nickname: account.nickname,
      region: account.region,
      self_introduction: account.self_introduction,
      portrait_url: portrait_path(account, [200, 200]),
      portrait_thumb_url: portrait_path(account, [40, 40])
    }
  end

  # 投稿カードに載せる投稿者情報
  def basic(account)
    {
      id: account.id,
      name: account.name,
      nickname: account.nickname,
      portrait_thumb_url: portrait_path(account, [40, 40])
    }
  end

  def portrait_path(account, size)
    return nil unless account.portrait.attached?

    # コントローラ外でも動くよう only_path を明示してプロキシ配信のパスを生成する
    Rails.application.routes.url_helpers.rails_storage_proxy_path(
      account.portrait.variant(resize_to_limit: size), only_path: true
    )
  end
end
