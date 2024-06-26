defmodule Persistence.Products.Products do
  import Ecto.Query

  alias Persistence.Products.Schema.Product
  alias Persistence.Stores.Schema.Store
  alias Persistence.Stores.Stores
  alias Persistence.Repo

  @doc """
  Example
  Receive the name store to insert the product
  iex> Persistence.Products.Products.create(
          "Test Store",
          %{
      product_name: "T-Shirt Adidas",
      description: "dryfit t-shirt",
      cod_product: "7898357411232",
      size: "xs",
      value: 105.99,
      quantity: 100,
      picture: "www.linkimage.com"
    })
  """
  @spec create(String.t(), map()) :: {:ok, Product.t()} | {:error, Ecto.Changeset.t()}
  def create(name_store, attrs) do
    with %Store{id: id} <- Stores.get_store_by_name(name_store),
         product_with_id <- Map.put(attrs, :id_store, id) do
      product_with_id
      |> Product.changeset()
      |> Repo.insert()
    end
  end

  @doc """
  Receive a store name and returns all products from store pagineted
  Example
  iex> Persistence.Products.Products.get_all_products_store("Test Store")
  """
  @spec get_all_products_store(String.t(), Integer.t(), Integer.t()) :: List.t() | []
  def get_all_products_store(name_store, page, page_size) do
    case Stores.get_store_by_name(name_store) do
      {:error, :not_found} ->
        {:error, :not_found}

      store ->
        %Persistence.Stores.Schema.Store{id: id} = store

        Product
        |> from()
        |> order_by([pt], desc: pt.inserted_at)
        |> limit(^page_size)
        |> offset((^page - 1) * ^page_size)
        |> where([pt], pt.id_store == ^id)
        |> Repo.all()
    end
  end

  @doc """
  Receive a cod product end returns the product
  Example
  iex> Persistence.Products.Products.get_by_cod_product("7898357411232")
  """

  @spec get_by_cod_product(String.t()) :: {:ok, Product.t()} | nil
  def get_by_cod_product(cod_product) do
    product =
      Product
      |> from()
      |> where([pt], pt.cod_product == ^cod_product)
      |> Repo.one()

    case product do
      nil ->
        {:error, :not_found}

      product ->
        {:ok, product}
    end
  end

  @doc """
  Receive a cod product and a nre atribute to be updated
  Example
  iex> Persistence.Products.Products.update("7898357411232", %{quantity: 20})
  """
  @spec update(String.t(), map()) :: {:ok, Product.t()} | {:error, Ecto.Changeset.t()}
  def update(cod_product, attrs) do
    case get_by_cod_product(cod_product) do
      {:error, :not_found} ->
        {:error, :not_found}

      {:ok, product} ->
        product
        |> Product.changeset(attrs)
        |> Repo.update()
    end
  end
end
