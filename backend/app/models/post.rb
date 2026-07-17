class Post < ApplicationRecord
  belongs_to :account
  has_many :tags, as: :taggable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many_attached :photos
  validates :title, presence: true, length: { maximum: 50 }
  validates :region, presence: true
  validates :description, presence: true
  validates :genre, presence: true
  # おおまか/位置なしでは apply_location_accuracy が place・座標をクリアするため精度別に必須条件を変える
  validates :place, presence: true, if: :location_accuracy_exact?
  validates :latitude, presence: true, unless: :location_accuracy_no_location?
  validates :longitude, presence: true, unless: :location_accuracy_no_location?
  validates :account_id, presence: true
  validates :photos, limit: { max: 4 }, content_type: %i(png jpg jpeg)
  enum :region, Region::REGIONS
  enum :prefecture, Prefecture::PREFECTURES, prefix: true
  enum :genre, {
    "オススメ" => 0,
    "駐輪場" => 1,
    "注意" => 2
  }
  # none は Post.none（ActiveRecord の null relation）と衝突するため no_location とする
  enum :location_accuracy, { exact: 0, approximate: 1, no_location: 2 }, prefix: true

  # おおまか投稿の丸め幅（度）。緯度 ≈ 1.1km / 経度 ≈ 0.9km（北緯35度付近）
  COARSE_GRID_STEP = 0.01

  # モデル層で丸め・クリアすることで、書き込み経路によらず生座標が DB に保存されないことを保証する
  before_validation :apply_location_accuracy

  scope :in_reverse_created_date_order, -> { order(created_at: "DESC") }
  scope :filter_by_region, ->(region) { where(region: region) }
  scope :filter_by_account_id, ->(account_id) { where(account_id: account_id) }

  def self.ransackable_attributes(auth_object = nil)
    ["account_id", "created_at", "description", "genre", "id", "latitude", "longitude", "place", "prefecture", "region", "title", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["account", "favorites", "photos_attachments", "photos_blobs", "tags"]
  end

  private

  def apply_location_accuracy
    if location_accuracy_approximate?
      self.latitude = round_coordinate(latitude) if latitude
      self.longitude = round_coordinate(longitude) if longitude
      self.place = nil
    elsif location_accuracy_no_location?
      self.latitude = nil
      self.longitude = nil
      self.place = nil
    end
  end

  # グリッドスナップ（冪等）: 再編集で座標が動かず、丸め済みの値しか API に現れない
  def round_coordinate(value)
    (value / COARSE_GRID_STEP).round * COARSE_GRID_STEP
  end
end
