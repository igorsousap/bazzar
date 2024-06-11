defmodule ClientWeb.ProductController do
  use ClientWeb, :controller

  require Logger

  alias Persistence.Products.Products
  alias Persistence.Users.Users
  alias Persistence.Stores.Stores

  action_fallback(ClientWeb.FallbackController)

  plug :put_view, json: ClientWeb.Jsons.ProductJson

  def create(conn, params) do
    with {:ok, user} <- authentication(params),
         {:ok, store} <- Stores.verify_id_store_from_user_id(user.id),
         {:ok, build_product} <- build_product_params(params),
         {:ok, product} <- Products.create(store.name_store, build_product) do
      conn
      |> put_status(:created)
      |> render(:product, layout: false, product: product)
    else
      nil ->
        Logger.error("Could not create product, invalid credentials access.}")

        {:error, :unauthorized}

      error ->
        Logger.error(
          "Could not create product with attributes #{inspect(params)}. Error: #{inspect(error)}"
        )

        error
    end
  end

  def products_by_store(conn, params) do
    with {:ok, user} <- authentication(params),
         {:ok, store} <- Stores.verify_id_store_from_user_id(user.id),
         {page, page_size} <- build_pagination(params["page"], params["page_size"]),
         products <- Products.get_all_products_store(store.name_store, page, page_size) do
      conn
      |> put_status(:ok)
      |> render(:product_pagination, layout: false, product: products)
    else
      nil ->
        Logger.error("Could not get products, invalid credentials access.}")

        {:error, :unauthorized}

      error ->
        Logger.error(
          "Could not find products with attributes #{inspect(params)}. Error: #{inspect(error)}"
        )

        error
    end
  end

  def product_by_cod(conn, params) do
    with {:ok, user} <- authentication(params),
         {:ok, _store} <- Stores.verify_id_store_from_user_id(user.id),
         {:ok, product} <- Products.get_by_cod_product(params["cod_product"]) do
      conn
      |> put_status(:ok)
      |> render(:product, layout: false, product: product)
    else
      nil ->
        Logger.error("Could not get products, invalid credentials access.}")

        {:error, :unauthorized}

      error ->
        Logger.error(
          "Could not find products with attributes #{inspect(params)}. Error: #{inspect(error)}"
        )

        error
    end
  end

  def update(conn, params) do
    with {:ok, user} <- authentication(params),
         {:ok, _store} <- Stores.verify_id_store_from_user_id(user.id),
         {:ok, product} <- Products.update(params["cod_product"], params) do
      conn
      |> put_status(:ok)
      |> render(:product, layout: false, product: product)
    else
      nil ->
        Logger.error("Could not get products, invalid credentials access.}")

        {:error, :unauthorized}

      error ->
        Logger.error(
          "Could not update store with attributes #{inspect(params)}. Error: #{inspect(error)}"
        )

        error
    end
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

  defp build_pagination(page, page_size) do
    page = String.to_integer(page)
    page_size = String.to_integer(page_size)

    {page, page_size}
  end

  defp authentication(params) do
    with {:ok, user} <- Users.get_user_by_email_and_password(params["email"], params["password"]),
         {:ok, _user} = Users.verify_token(user.id) do
      {:ok, user}
    end
  end
end
