module Api
  module V1
    class MetaController < BaseController
      # enum 定義などフロントエンドと共有するメタ情報。
      # サインアップ画面（未ログイン）でも使うため認証不要。
      def show
        render json: {
          regions: Region::REGIONS.map { |label, value| { label: label, value: value } },
          prefectures: Prefecture::PREFECTURES.map { |label, value| { label: label, value: value } },
          genres: Post.genres.map { |label, value| { label: label, value: value } },
          prefecture_to_region: Region::PREFECTURE_TO_REGION
        }
      end
    end
  end
end
