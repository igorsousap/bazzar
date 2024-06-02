defmodule ClientWeb.Router do
  use ClientWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/store", ClientWeb do
    pipe_through :api

    post "/", StoreController, :create
    get "/", StoreController, :index
    get "/store-name/:name_store", StoreController, :get_store_by_name
    get "/store-cnpj/:cnpj", StoreController, :get_store_by_cnpj
    put "/", StoreController, :update
  end

  scope "/api/product", ClientWeb do
    pipe_through :api

    post "/", ProductController, :create
    get "/:name_store", ProductController, :products_by_store
    get "/cod/:cod_product", ProductController, :product_by_cod
    put "/", ProductController, :update
  end

  scope "/api/user", ClientWeb do
    pipe_through :api

    post "/", UserController, :register_user
    get "/", UserController, :get_user
    put "/", UserController, :change_email_or_password
    post "/new-token", UserController, :generate_new_token
  end
end
