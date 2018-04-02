class Product < ApplicationRecord
  enum tax: {default: 0, free: 1}
  enum type_product: {inland: 0, import: 1}

  validates :name, presence: true, length: {minimum: Settings.name_product.minimum,
    maximum: Settings.name_product.maximum}
  validates :price, presence: true, numericality: {greater_than: 0}
end
