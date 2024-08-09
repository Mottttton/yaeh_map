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
  enum genre: {
    オススメ: 0,
    駐輪場: 1,
    注意: 2
  }

  scope :in_reverse_created_date_order, -> () {order(created_at: "DESC")}
  scope :filter_by_region, -> (region) {where(region: region)}
  scope :filter_by_account_id, -> (account_id) {where(account_id: account_id)}

  def self.ransackable_attributes(auth_object = nil)
    ["account_id", "created_at", "description", "genre", "id", "latitude", "longitude", "place", "prefecture", "region", "title", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["account", "favorites", "photos_attachments", "photos_blobs", "tags"]
  end
end
