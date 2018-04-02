$(document).ready(function() {
  $(document).on('click', 'span.shopping-cart', function() {
    $(this).toggleClass('color-red');
    $('div.container-shopping-item').toggleClass('container-shopping-open');
  });

  $(document).on('click', '.add-shopping-cart', function() {
    var id = $(this).closest('.item').parent().data('product-id');
    var name = $(this).data('product-name');
    var price = parseFloat($(this).data('product-price'));
    var item = $('.container-shopping-item div[data-product-id=' + id + ']');
    var this_button = $(this);
    var tax = $(this).data('product-tax');
    var type = $(this).data('product-type');
    var tax_product = 0
    var total_price = 0;
    if (tax == "default") {
      tax_product = price * 10 / 100;
    }
    if (type == "import") {
      tax_product += price * 5 / 100;
    }
    tax_product = Math.ceil(tax_product * 20) / 20.0;
    var total_price = price + tax_product;
    $.ajax({
      url: '/update_cart_sessions',
      type: 'PATCH',
      data: {product_id: id, quantity: 1},
      dataType: 'JSON',
      success: function() {
        var add_product = '<div class="cart-item" data-product-id="' + id + '" data-product-tax="' + tax + '"'
          + ' data-product-type="' + type + '">'
          + '<p class="text-right"><span class="remove-cart-item">&times;</span></p>'
          + '<p><strong>' + name + '</strong></p><p class="item-price" data-price="' + price
          +'">$' + price + '</p>'
          + '<span class="glyphicon glyphicon-minus-sign change-quantity hide"></span>'
          + '<input type="number" class="quantity text-center" value="1" step="1" />'
          + '<span class="glyphicon glyphicon-plus-sign change-quantity"></span>'
          + '<p class="text-right">' + I18n.t('sales_taxes') + ' $' + '<span class="tax-price">'
          + tax_product + '</span>&ensp;' + I18n.t('total_price') + ' $'
          + '<span class="total-price">' + total_price.toFixed(2) + '</span></p></div>';
        $('.container-shopping-item .shopping-item').append(add_product);
        $('.cart-not-have-product').addClass('hide');
        $('.total-price-cart-item').removeClass('hide');
        $('div.export-pdf').removeClass('hide');
        this_button.addClass('hide');
        calculateTotalPriceAllProduct();
      }
    });
  });

  $(document).on('click', '.change-quantity.glyphicon-plus-sign', function() {
    var id = $(this).closest('.cart-item').data('product-id');
    var input_quantity = $(this).closest('.cart-item').find('input');
    var current_quantity = parseInt(input_quantity.val());
    input_quantity.val(current_quantity + 1);
    limitInput(input_quantity);
    calculateTotalPriceEachProduct(input_quantity);
    calculateTotalPriceAllProduct();
    ajaxUpdateCartSession(id, current_quantity + 1, null);
  });

  $(document).on('click', '.change-quantity.glyphicon-minus-sign', function() {
    var id = $(this).closest('.cart-item').data('product-id');
    var input_quantity = $(this).closest('.cart-item').find('input');
    var current_quantity = parseInt(input_quantity.val());
    input_quantity.val(current_quantity - 1);
    limitInput(input_quantity);
    calculateTotalPriceEachProduct(input_quantity);
    calculateTotalPriceAllProduct();
    ajaxUpdateCartSession(id, current_quantity - 1, null);
  });

  $(document).on('click', '.remove-cart-item', function() {
    var id = $(this).closest('.cart-item').data('product-id');
    $(this).closest('.cart-item').remove();
    ajaxUpdateCartSession(id, null, true);
    calculateTotalPriceAllProduct();
    $('div[data-product-id=' + id + '] .item .add-shopping-cart').removeClass('hide');
    if ($(document).find('.cart-item').length == 0) {
      $('.cart-not-have-product').removeClass('hide');
      $('.total-price-cart-item').addClass('hide');
      $('div.export-pdf').addClass('hide');
    }
  });

  $(document).on('change', 'input.quantity', function() {
    var id = $(this).closest('.cart-item').data('product-id');
    var current_quantity = $(this).val();
    limitInput($(this));
    calculateTotalPriceEachProduct($(this));
    calculateTotalPriceAllProduct();
    ajaxUpdateCartSession(id, current_quantity, null);
  });

  // Limit quantity for each product in cart
  function limitInput(input) {
    var quantity = parseFloat(input.val());
    var cart_item = input.closest('.cart-item');
    var plus = cart_item.find('span.glyphicon-plus-sign');
    var minus = cart_item.find('span.glyphicon-minus-sign');
    if (quantity < 1) {
      input.val(1);
      minus.addClass('hide');
      plus.removeClass('hide');
    } else if (quantity > 20) {
      input.val(20);
      minus.removeClass('hide');
      plus.addClass('hide');
    } else if (quantity == 1) {
      minus.addClass('hide');
      plus.removeClass('hide');
    } else if (quantity == 20) {
      minus.removeClass('hide');
      plus.addClass('hide');
    } else {
      minus.removeClass('hide');
      plus.removeClass('hide');
    }
  };

  // Calculate tax and total price only product
  function calculateTotalPriceEachProduct(input) {
    var quantity = parseFloat(input.val());
    var cart_item = input.closest('.cart-item');
    var price = parseFloat(cart_item.find('.item-price').data('price'));
    var tax = cart_item.data('product-tax');
    var type = cart_item.data('product-type');
    var tax_product = 0;
    if (tax == "default") {
      tax_product = price * 10 / 100;
    }
    if (type == "import") {
      tax_product += price * 5 / 100;
    }
    var tax_price = ((Math.ceil(tax_product * 20) / 20) * quantity).toFixed(2);
    var total_price = ((price + (Math.ceil(tax_product * 20) / 20)) * quantity).toFixed(2);
    cart_item.find('.tax-price').html(tax_price);
    cart_item.find('.total-price').html(total_price);
  }

  // Calculate tax and total price all product
  function calculateTotalPriceAllProduct() {
    var all_item = $(document).find('.cart-item');
    var tax_all = 0;
    var total_price = 0;
    $.each(all_item, function(index, item) {
      var quantity = parseFloat($(item).find('input.quantity').val());
      var price = parseFloat($(item).find('.item-price').data('price'));
      var tax = $(item).data('product-tax');
      var type = $(item).data('product-type');
      var tax_product = 0;
      if (tax == "default") {
        tax_product = price * 10 / 100;
      }
      if (type == "import") {
        tax_product += price * 5 / 100;
      }
      tax_all += Math.ceil(tax_product * quantity * 20) / 20.0;
      total_price += price * quantity;
    });
    $('.total-price-cart-item .tax-all').html(tax_all.toFixed(2));
    $('.total-price-cart-item .total-price-all').html((total_price + tax_all).toFixed(2));
  }


  // Send ajax to update cart session controller
  function ajaxUpdateCartSession(id, quantity, is_delete) {
    $.ajax({
      url: '/update_cart_sessions',
      type: 'PATCH',
      data: {product_id: id, quantity: quantity, is_delete: is_delete},
      dataType: 'JSON'
    });
  }
});
