class Post < ApplicationRecord
  belongs_to :account
  has_many :tags, as: :taggable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy
  validates :title, presence: true, length: { maximum: 50 }
  validates :region, presence: true
  validates :description, presence: true
  validates :genre, presence: true
  validates :place_id, presence: true
  validates :account_id, presence: true
  enum region: Region.regions
  enum prefecture: Prefecture.prefectures, _prefix: true
  enum genre: %i(注意 駐車場 路面 事故 工事 通行止め)
end
