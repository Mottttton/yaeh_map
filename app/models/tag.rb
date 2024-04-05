class Tag < ApplicationRecord
  belongs_to :account
  belongs_to :taggable, polymorphic: true
end
