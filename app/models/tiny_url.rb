class TinyUrl < ApplicationRecord
  self.table_name = "tiny_urls"

  validates :alias, presence: true, uniqueness: true
  validates :original_url, presence: true
end
