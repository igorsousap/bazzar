defmodule ClientWeb.ProductController do
  use ClientWeb, :controller

  require Logger

  alias Persistence.Products.Products

  action_fallback(ClientWeb.FallbackController)

  plug :put_view, json: ClientWeb.Jsons.ProductJson

  def create(conn, params) do
    with {:ok, name_store} <- Map.fetch(params, "name_store"),
         product <- Map.delete(params, "name_store"),
         {:ok, build_product} <- build_product_params(product),
         {:ok, product} <- Products.create(name_store, build_product) do
      conn
      |> put_status(:created)
      |> render(:product, layout: false, product: product)
    else
      error ->
        Logger.error(
          "Could not create product with attributes #{inspect(params)}. Error: #{inspect(error)}"
        )

        error
    end
  end

  def products_by_store(conn, params) do
    page = String.to_integer(params["page"])
    page_size = String.to_integer(params["page_size"])
    products = Products.get_all_products_store(params["name_store"], page, page_size)

    conn
    |> put_status(:ok)
    |> render(:product_index, layout: false, product: products)
  end

  defp build_product_params(params) do
    params = %{
      product_name: params["product_name"],
      description: params["description"],
      cod_product: params["cod_product"],
      size: params["size"],
      value: params["value"],
      quantity: params["quantity"],
      picture: params["picture"]
    }

    {:ok, params}
  end
end
