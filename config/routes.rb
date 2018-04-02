Rails.application.routes.draw do
  root "products#index"

  resources :products, only: %i(index new create destroy)
  resource :update_cart_sessions, only: :update
  resource :export_pdfs, only: :show
end
