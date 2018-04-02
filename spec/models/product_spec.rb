require "rails_helper"

RSpec.describe Product, type: :model do
  context "columns" do
    it {is_expected.to have_db_column(:name).of_type :string}
    it {is_expected.to have_db_column(:price).of_type :float}
    it {is_expected.to have_db_column(:tax).of_type :integer}
    it {is_expected.to have_db_column(:type_product).of_type :integer}
  end

  context "validates" do
    it {is_expected.to validate_presence_of :name}
    it {is_expected.to validate_length_of(:name).is_at_least Settings.name_product.minimum}
    it {is_expected.to validate_length_of(:name).is_at_most Settings.name_product.maximum}
    it {is_expected.to validate_presence_of :price}
    it {is_expected.to validate_numericality_of(:price).is_greater_than 0}
  end
end
