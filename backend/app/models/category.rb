class Category < ApplicationRecord
  has_many :balances, foreign_key: 'large_category_id'

  enum size: { small: 1, medium: 2, large: 3 }
end
