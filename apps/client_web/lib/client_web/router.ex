defmodule ClientWeb.Router do
  use ClientWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ClientWeb do
    pipe_through :api

    post "/store", StoreControlle, :create
  end
end
