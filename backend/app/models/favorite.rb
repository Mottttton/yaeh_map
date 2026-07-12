class Favorite < ApplicationRecord
  belongs_to :account
  belongs_to :favoritable, polymorphic: true
  validates :account_id, uniqueness: { scope: %i(favoritable_id favoritable_type)}

  scope :search_posts, ->() { find_by(favoritable_type: 'Post') }
  scope :search_post, ->(post) { find_by(favoritable_type: 'Post', favoritable_id: post.id) }
  scope :search_account, ->(account) { find_by(account_id: account.id) }
end
