require "rails_helper"

RSpec.describe UpdateCartSessionsController, type: :controller do
  let! (:create_products) {FactoryGirl.create_list(:product, 5)}

  describe "POST #update" do
    context "when session cart is empty" do
      before do
        session[:cart] = {}
        patch :update, xhr: true, params: {product_id: Product.first.id, quantity: 1, is_delete: nil}

      end

      it "sesson cart change size" do
        item = {}
        item[Product.first.id.to_s] = [Product.first, "1"]
        expect(session[:cart].size).to eq 1
      end

      it "sesson cart have new item" do
        item = {}
        item[Product.first.id.to_s] = [Product.first, "1"]
        expect(session[:cart]).to eq item
      end
    end

    context "when session cart have item but not have product send" do
      before do
        session[:cart] = {}
        session[:cart][Product.first.id.to_s] = [Product.first, "1"]
        patch :update, xhr: true, params: {product_id: Product.second.id, quantity: 1, is_delete: nil}
      end

      it "sesson cart change size" do
        expect(session[:cart].size).to eq 2
      end

      it "sesson cart have new item" do
        item = [Product.second, "1"]
        expect(session[:cart][Product.second.id.to_s]).to eq item
      end
    end

    context "update quantity when session cart have product send" do
      before do
        session[:cart] = {}
        session[:cart][Product.first.id.to_s] = [Product.first, "1"]
        patch :update, xhr: true, params: {product_id: Product.first.id, quantity: 5, is_delete: nil}
      end

      it "session cart not change size" do
        expect(session[:cart].size).to eq 1
      end

      it "quantity change" do
        expect(session[:cart][Product.first.id.to_s].last).to eq "5"
      end
    end

    context "remove product from session cart" do
      before do
        session[:cart] = {}
        session[:cart][Product.first.id.to_s] = [Product.first, "1"]
        patch :update, xhr: true, params: {product_id: Product.first.id, quantity: 5, is_delete: true}
      end

      it "session cart change size" do
        expect(session[:cart].size).to eq 0
      end

      it "quantity change" do
        expect(session[:cart]).to eq Hash.new
      end
    end
  end
end
