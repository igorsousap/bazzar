defmodule ClientWeb.Router do
  use ClientWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug ClientWeb.Plugs.AuthPipeline
  end

  scope "/api/store", ClientWeb do
    pipe_through [:api, :auth]

    post "/", StoreController, :create
    put "/", StoreController, :update
  end

  scope "/api", ClientWeb do
    pipe_through :api

    get "/stores", StoreController, :index
    get "/search/stores/:name_store", StoreController, :get_store_by_name
    get "/search/stores/cnpj/:cnpj", StoreController, :get_store_by_cnpj
  end

  scope "/api/product", ClientWeb do
    pipe_through [:api, :auth]

    post "/", ProductController, :create
    get "/", ProductController, :products_by_store
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

  scope "/api/session", ClientWeb do
    pipe_through :api

    post "/", SessionController, :create
  end
end
