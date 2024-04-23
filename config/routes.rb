Rails.application.routes.draw do
  resources :stocks, only: [:index, :show, :create]
  resources :warehouses
  resources :products
  resources :orders, only: [:index, :show, :create]
  patch "dispatch_order/:id", to: "orders#update"
  get "stock_balance/:warehouse_id/:product_id", to: "stock_balance#show"
end
