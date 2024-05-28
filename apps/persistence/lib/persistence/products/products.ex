defmodule Persistence.Products.Products do
  import Ecto.Query

  alias Persistence.Products.Schema.Product
  alias Persistence.Stores.Stores
  alias Persistence.Repo

  @doc """
  Example
  iex> Persistence.Products.Products.create(
          "IgorStore",
          %{
          product_name: "Blusa adidas",
          description: "regata azul com simbolo branco",
          cod_product: "7898357411232",
          size: "xs",
          value: 105.99,
          quantity: 100,
          picture: "www.linkimage.com"
           })
  """
  @spec create(String.t(), map()) :: {:ok, Product.t()} | {:error, Ecto.Changeset.t()}
  def create(name_store, attrs) do
    with {:ok, %Persistence.Stores.Schemas.Store{id: id}} <- Stores.get_store_by_name(name_store),
         product_with_id <- Map.put(attrs, :id_store, id) do
      product_with_id
      |> Product.changeset()
      |> Repo.insert()
    end
  end

  @doc """
  Example
  iex> Persistence.Products.Products.get_all_products_store("IgorStore")
  """

  @spec get_all_products_store(String.t()) :: List.t() | []
  def get_all_products_store(name_store) do
    {:ok, %Persistence.Stores.Schemas.Store{id: id}} = Stores.get_store_by_name(name_store)

    Product
    |> from()
    |> where([pt], pt.id == ^id)
    |> Repo.all()
  end

  @doc """
  Example
  iex> Persistence.Products.Products.get_by_cod_product("7898357411232")
  """

  @spec get_by_cod_product(String.t()) :: {:ok, Product.t()} | nil
  def get_by_cod_product(cod_product) do
    Product
    |> from()
    |> where([pt], pt.cod_product == ^cod_product)
    |> Repo.one()
  end

  @doc """
  Example
  iex> Persistence.Products.Products.update("7898357411232", %{quantity: 20})
  """
  @spec update(String.t(), map()) :: {:ok, Product.t()} | {:error, Ecto.Changeset.t()}
  def update(cod_product, attrs) do
    {:ok, product} = get_by_cod_product(cod_product)

    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end
end
