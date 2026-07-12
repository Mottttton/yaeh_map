module Api
  module V1
    class BaseController < ApplicationController
      # enum に不正な値を代入した場合など（例: region に存在しない地域名）を 422 で返す
      rescue_from ArgumentError do |exception|
        render json: { errors: [exception.message] }, status: :unprocessable_entity
      end

      private

      def require_signin!
        render json: { error: I18n.t("notice.require_sign_in") }, status: :unauthorized unless account_signed_in?
      end

      def require_admin!
        render json: { error: I18n.t("notice.reject") }, status: :forbidden unless current_account&.admin?
      end

      def render_errors(record)
        render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
      end

      def pagination_meta(scope)
        {
          current_page: scope.current_page,
          total_pages: scope.total_pages,
          total_count: scope.total_count,
          per_page: scope.limit_value
        }
      end
    end
  end
end
