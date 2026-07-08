require 'rails_helper'

RSpec.describe 'Api::V1::Meta', type: :request do
  describe 'GET /api/v1/meta' do
    it 'enum 定義を返す（認証不要）' do
      get api_v1_meta_path
      expect(response).to have_http_status(200)

      body = response.parsed_body
      expect(body['regions'].size).to eq 10
      expect(body['regions']).to include('label' => '九州', 'value' => 8)
      expect(body['prefectures'].size).to eq 47
      expect(body['genres'].map { |genre| genre['label'] }).to eq %w(オススメ 駐輪場 注意)
      # 九州の都道府県は「九州」地域に対応する（旧 JS では不正な「鹿児島」を返すバグがあった）
      expect(body['prefecture_to_region']['福岡']).to eq '九州'
      expect(body['prefecture_to_region']['東京']).to eq '関東'
    end
  end
end
