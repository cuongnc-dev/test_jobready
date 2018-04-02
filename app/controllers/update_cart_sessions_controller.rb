class UpdateCartSessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def update
    if params[:is_delete].present?
      session[:cart].except! params[:product_id].to_s
    else
      product = Product.find_by id: params[:product_id]
      session[:cart][params[:product_id]] = [product, params[:quantity]]
    end
  end
end
