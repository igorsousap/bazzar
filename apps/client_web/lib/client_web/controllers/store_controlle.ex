defmodule ClientWeb.StoreControlle do
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
