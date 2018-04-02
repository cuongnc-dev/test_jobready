class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name
      t.float :price
      t.integer :tax
      t.integer :type_product

      t.timestamps
    end
  end
end
