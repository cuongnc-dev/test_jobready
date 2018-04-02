class Product < ApplicationRecord
  enum tax: {default: 0, free: 1}
  enum type_product: {inland: 0, import: 1}

  validates :price, presence: true, numericality: {only_float: true, greater_than: 0}
end
