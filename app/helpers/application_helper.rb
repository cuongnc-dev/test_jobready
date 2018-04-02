module ApplicationHelper
  def calculate_tax value
    product = value.first
    price = product["price"].to_f
    tax = product["tax"]
    type = product["type_product"]
    tax_product = 0
    if tax == Settings.tax.default
      tax_product = price * 10 / 100
    end
    if type == Settings.type.import
      tax_product += price * 5 /100
    end
    quantity = value.last.to_f
    (((tax_product * quantity) * 20).ceil / 20.0).round 2
  end

  def calculate_total_price value
    tax = calculate_tax value
    price = value.first["price"].to_f
    quantity = value.last.to_f
    (price * quantity + tax).round 2
  end

  def calculate_tax_all
    tax_all = 0
    session[:cart].each do |key, value|
      tax_all += calculate_tax value
    end
    tax_all.round 2
  end

  def calculate_price_all
    total_price = 0
    session[:cart].each do |key, value|
      total_price += calculate_total_price value
    end
    total_price.round 2
  end
end
