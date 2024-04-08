class Favorite < ApplicationRecord
  belongs_to :account
  belongs_to :favoritable, polymorphic: true
  validates :account_id, uniqueness: { scope: %i(favoritable_id favoritable_type)}
end
