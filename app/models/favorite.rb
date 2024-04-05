class Favorite < ApplicationRecord
  belongs_to :account
  belongs_to :favoritable, polymorphic: true
end
