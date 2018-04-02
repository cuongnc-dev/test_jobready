class ProductsController < ApplicationController
  before_action :load_product, only: %i(edit update destroy)
  before_action :set_session_cart

  def index
    @products = Product.all
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new product_params
    if @product.save
      @products = Product.all
      @success = true
      @message = t ".create_success"
    else
      @success = false
    end
  end

  def destroy
    @product = Product.find_by id: params[:id]
    if @product.destroy
      if session[:cart][@product.id.to_s].present?
        session[:cart].except! @product.id.to_s
      end
      @success = true
      @message = t ".delete_success"
    else
      @success = false
      @message = t ".delete_fail"
    end
  end

  private

  def product_params
    params.require(:product).permit :name, :price, :tax, :type_product

  end

  def load_product
    @product = Product.find_by id: params[:id]
    return if @product
    flash[:alert] = t "product_not_found"
    redirect_to root_path
  end

  def set_session_cart
    session[:cart] = {} unless session[:cart].present?
  end
end
