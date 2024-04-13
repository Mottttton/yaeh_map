class Post < ApplicationRecord
  belongs_to :account
  has_many :tags, as: :taggable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many_attached :photos
  validates :title, presence: true, length: { maximum: 50 }
  validates :region, presence: true
  validates :description, presence: true
  validates :genre, presence: true
  validates :place, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :account_id, presence: true
  validates :photos, limit: { max: 4 }, content_type: %i(png jpg jpeg)
  enum region: Region.regions
  enum prefecture: Prefecture.prefectures, _prefix: true
  enum genre: %i(注意 駐車場 路面 事故 工事 通行止め)

  scope :in_reverse_created_date_order, -> () {order(created_at: "DESC")}
end
