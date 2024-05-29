defmodule ClientWeb.StoreController do
  use ClientWeb, :controller

  require Logger

  alias Persistence.Stores.Stores

  action_fallback(ClientWeb.FallbackController)

  plug :put_view, json: ClientWeb.Jsons.StoreJson

  def create(conn, params) do
    with {:ok, params} <- build_store_params(params),
         {:ok, store} <- Stores.create(params) do
      conn
      |> put_status(:created)
      |> render(:store, layout: false, store: store)
    else
      error ->
        Logger.error(
          "Could not create store with attributes #{inspect(params)}. Error: #{inspect(error)}"
        )

        error
    end
  end

  def index(conn, params) do
    page = String.to_integer(params["page"])
    page_size = String.to_integer(params["page_size"])
    stores = Stores.get_all_stores(page, page_size)

    conn
    |> put_status(:ok)
    |> render(:store_index, layout: false, store: stores)
  end

  def get_store_by_name(conn, params) do
    store = Stores.get_store_by_name(params["name_store"])

    conn
    |> put_status(:ok)
    |> render(:store, layout: false, store: store)
  end

  def get_store_by_cnpj(conn, params) do
    store = Stores.get_store_by_cnpj(params["cnpj"])

    conn
    |> put_status(:ok)
    |> render(:store, layout: false, store: store)
  end

  def update(conn, params) do
    {:ok, store} = Stores.update_by_name_store(params["name_store"], params)

    conn
    |> put_status(:ok)
    |> render(:store, layout: false, store: store)
  end

  defp build_store_params(params) do
    params = %{
      name_store: params["name_store"],
      description: params["description"],
      adress: params["adress"],
      neighborhood: params["neighborhood"],
      number: params["number"],
      cep: params["cep"],
      cnpj: params["cnpj"],
      phone: params["phone"]
    }

    {:ok, params}
  end
end
