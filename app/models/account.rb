class Account < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :favorites, dependent: :destroy
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :nickname, presence: true, length: { maximum: 50 }
  validates :self_introduction, length: { maximum: 500 }
  enum region: Region.regions, _prefix: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable
end
