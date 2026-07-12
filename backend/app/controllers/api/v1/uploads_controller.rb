module Api
  module V1
    # 画像の二段階アップロード用 API。
    # ファイル選択時に未添付の blob を作成して signed_id を返し、
    # フォーム送信時に signed_id を portrait / photos へ添付して確定する。
    # 確定前に画面を離れる場合はフロントエンドが DELETE で blob を破棄する。
    class UploadsController < BaseController
      before_action :require_signin!

      ALLOWED_CONTENT_TYPES = %w(image/png image/jpeg).freeze
      MAX_FILE_SIZE = 10.megabytes

      def create
        file = params.require(:file)
        error = validate_file(file)
        return render json: { errors: [error] }, status: :unprocessable_entity if error

        blob = ActiveStorage::Blob.create_and_upload!(
          io: file,
          filename: file.original_filename,
          content_type: file.content_type
        )
        render json: {
          signed_id: blob.signed_id,
          url: rails_storage_proxy_path(blob, only_path: true)
        }, status: :created
      end

      def destroy
        blob = ActiveStorage::Blob.find_signed(params[:signed_id])
        return head :not_found if blob.nil?
        # 添付済み（保存確定済み）の blob は消させない。削除できるのは未確定のアップロードのみ
        return render json: { errors: [I18n.t("uploads.destroy.attached")] }, status: :unprocessable_entity if blob.attachments.exists?

        blob.purge
        head :no_content
      end

      private

      def validate_file(file)
        return I18n.t("uploads.create.invalid_file") unless file.respond_to?(:content_type)
        return I18n.t("uploads.create.invalid_content_type") unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
        return I18n.t("uploads.create.too_large") if file.size > MAX_FILE_SIZE

        nil
      end
    end
  end
end
