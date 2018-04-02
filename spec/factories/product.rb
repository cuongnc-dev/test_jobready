FactoryGirl.define do
  factory :product do
    name {Faker::Name.name}
    price {Faker::Number.decimal 2}
    tax 0
    type_product 0
  end
end
