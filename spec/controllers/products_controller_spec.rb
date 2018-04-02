require "rails_helper"

RSpec.describe ProductsController, type: :controller do
  describe "GET #index" do
    let! (:create_products) {FactoryGirl.create_list(:product, 5)}

    before do
      get :index
    end

    it "success status" do
      expect(response).to have_http_status :success
    end

    it "should render right template view" do
      expect(response).to render_template :index
    end

    it "should have right list of products when first load" do
      expect((assigns :products).size).to eq 5
    end

    context "should have sessions cart when first load" do
      it "when session cart not present" do
        expect(session[:cart]).to eq Hash.new
      end

      it "when session cart existed" do
        product = Product.first
        product1 = Product.second
        session[:cart] = {}
        session[:cart][product.id] = [product, "1"]
        session[:cart][product1.id] = [product1, "1"]
        item = {}
        item[product.id] = [product, "1"]
        item[product1.id] = [product1, "1"]
        get :index
        expect(session[:cart]).to eq item
      end
    end
  end

  describe "GET #new" do
    before do
      get :new, xhr: true
    end

    it "success status" do
      expect(response).to have_http_status :success
    end

    it "should render right template view" do
      expect(response).to render_template :new
    end

    it "should have right list off request when first load" do
      expect((assigns :product).id).to eq nil
    end
  end

  describe "POST #create" do
    before do
      post :create, xhr: true, params: {product: {name: Faker::Name.name ,
        price: Faker::Number.decimal(2), tax: :free, type_product: :inland}}
    end

    context "create product success" do
      let :send_create do
        post :create, xhr: true, params: {product: {name: Faker::Name.name,
          price: Faker::Number.decimal(2), tax: :free, type_product: :inland}}
      end

      it "increase number product by 1" do
        expect{send_create}.to change(Product, :count).by 1
      end

      it "correct message success" do
        send_create
        expect((assigns :message)).to eq I18n.t("products.create.create_success")
      end

      it "correct status success" do
        send_create
        expect((assigns :success)).to eq true
      end
    end

    describe "create product fail" do
      describe "fail cause params name" do
        context "cause params name is blank" do
          let :invalid_params do
            post :create, xhr: true, params: {product: {name: "",
              price: Faker::Number.decimal(2), tax: :free, type_product: :inland}}
          end

          it "not increase number product" do
            expect{invalid_params}.to change(Product, :count).by 0
          end

          it "correct status success" do
            invalid_params
            expect((assigns :success)).to eq false
          end

          it "error name product too short" do
            invalid_params
            expect((assigns :product).errors[:name]).to include
              I18n.t("activerecord.errors.models.product.attributes.name.blank")
          end
        end

        context "cause params name too short" do
          let :invalid_params do
            post :create, xhr: true, params: {product: {name: "abc",
              price: Faker::Number.decimal(2), tax: :free, type_product: :inland}}
          end

          it "not increase number product" do
            expect{invalid_params}.to change(Product, :count).by 0
          end

          it "correct status success" do
            invalid_params
            expect((assigns :success)).to eq false
          end

          it "error name product too short" do
            invalid_params
            expect((assigns :product).errors[:name]).to include
              I18n.t("activerecord.errors.models.product.attributes.name.too_short",
                count: Settings.name_product.minimum)
          end
        end

        context "cause params name too long" do
          let :invalid_params do
            post :create, xhr: true, params: {product: {name: Faker::Lorem.words(51),
              price: Faker::Number.decimal(2), tax: :free, type_product: :inland}}
          end

          it "not increase number product" do
            expect{invalid_params}.to change(Product, :count).by 0
          end

          it "correct status fail" do
            invalid_params
            expect((assigns :success)).to eq false
          end

          it "error name product too long" do
            invalid_params
            expect((assigns :product).errors[:name]).to include
              I18n.t("activerecord.errors.models.product.attributes.name.too_long",
                count: Settings.name_product.maximum)
          end
        end
      end

      describe "fail cause params price" do
        context "cause params price less than 0" do
          let :invalid_params do
            post :create, xhr: true, params: {product: {name: Faker::Name.name,
              price: -1, tax: :free, type_product: :inland}}
          end

          it "not increase number product" do
            expect{invalid_params}.to change(Product, :count).by 0
          end

          it "correct status fail" do
            invalid_params
            expect((assigns :success)).to eq false
          end

          it "error name product too long" do
            invalid_params
            expect((assigns :product).errors[:price]).to include
              I18n.t("activerecord.errors.models.product.attributes.price.greater_than",
                count: 0)
          end
        end

        context "cause params price not a number" do
          let :invalid_params do
            post :create, xhr: true, params: {product: {name: Faker::Name.name,
              price: "abc", tax: :free, type_product: :inland}}
          end

          it "not increase number product" do
            expect{invalid_params}.to change(Product, :count).by 0
          end

          it "correct status fail" do
            invalid_params
            expect((assigns :success)).to eq false
          end

          it "error name product too long" do
            invalid_params
            expect((assigns :product).errors[:price]).to include
              I18n.t("activerecord.errors.models.product.attributes.price.not_a_number")
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let! (:product) {FactoryGirl.create :product}
    let (:send_delete) {delete :destroy, xhr: true, params: {id: product.id}}

    context "destroy success" do
      it "decrease number product by 1" do
        expect{send_delete}.to change(Product, :count).by -1
      end

      it "correct message success" do
        send_delete
        expect((assigns :message)).to eq I18n.t("products.destroy.delete_success")
      end

      it "correct status success" do
        send_delete
        expect((assigns :success)).to eq true
      end

      it "remove product from session card" do
        session[:cart] = {}
        session[:cart][product.id.to_s] = [product, "1"]
        send_delete
        expect(session[:cart]).to eq Hash.new
      end
    end

    describe "destroy fail" do
      context "cause product id not exist" do
        before do
          delete :destroy, xhr: true, params: {id: 0}
        end

        it "flash message when not found product" do
          expect(flash[:alert]).to eq I18n.t("product_not_found")
        end

        it "redirect to root" do
          expect(response).to redirect_to root_path
        end
      end

      context "cause other reason" do
        before do
          allow_any_instance_of(Product).to receive(:destroy).and_return false
        end

        it "not change number product" do
          send_delete
          expect{send_delete}.to change(Product, :count).by 0
        end

        it "message delete fail" do
          send_delete
          expect((assigns :message)).to eq I18n.t("products.destroy.delete_fail")
        end

        it "assigns success fail" do
          send_delete
          expect((assigns :success)).to eq false
        end
      end
    end
  end
end
