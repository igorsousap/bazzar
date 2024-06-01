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
    {page, page_size} = build_pagination(params["page"], params["page_size"])

    case Stores.get_all_stores(page, page_size) do
      nil ->
        Logger.error("Could not find any store.")
        {:error, :not_found}

      stores ->
        conn
        |> put_status(:ok)
        |> render(:store_index, layout: false, store: stores)
    end
  end

  def get_store_by_name(conn, params) do
    case Stores.get_store_by_name(params["name_store"]) do
      nil ->
        Logger.error("Could not find store with attributes #{inspect(params)}.")

        {:error, :not_found}

      store ->
        conn
        |> put_status(:ok)
        |> render(:store, layout: false, store: store)
    end
  end

  def get_store_by_cnpj(conn, params) do
    case Stores.get_store_by_cnpj(params["cnpj"]) do
      nil ->
        Logger.error("Could not find store with attributes #{inspect(params)}.")

        {:error, :not_found}

      store ->
        conn
        |> put_status(:ok)
        |> render(:store, layout: false, store: store)
    end
  end

  def update(conn, params) do
    case Stores.update_by_name_store(params["name_store"], params) do
      {:ok, store} ->
        conn
        |> put_status(:ok)
        |> render(:store, layout: false, store: store)

      error ->
        Logger.error(
          "Could not update store with attributes #{inspect(params)}. Error: #{inspect(error)}"
        )

        error
    end
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

  defp build_pagination(page, page_size) do
    page = String.to_integer(page)
    page_size = String.to_integer(page_size)

    {page, page_size}
  end
end
