defmodule ClientWeb.Router do
  use ClientWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ClientWeb do
    pipe_through :api

    post "/store", StoreController, :create
    get "/store", StoreController, :index
    get "/store-name/:name_store", StoreController, :get_store_by_name
    get "/store-cnpj/:cnpj", StoreController, :get_store_by_cnpj
    put "/store", StoreController, :update

    post "/product", ProductController, :create
    get "/product/:name_store", ProductController, :products_by_store
    get "/product/cod/:cod_product", ProductController, :product_by_cod
    put "/product", ProductController, :update
  end
end
