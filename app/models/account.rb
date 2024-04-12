class Account < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :favorites, dependent: :destroy
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }, format: { with: /\A[\w]+[\w]\z/ }
  validates :email, presence: true, uniqueness: true, length: { maximum: 255 }, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  }
  validates :nickname, presence: true, length: { maximum: 50 }
  validates :self_introduction, length: { maximum: 500 }
  enum region: Region.regions, _prefix: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable
end
