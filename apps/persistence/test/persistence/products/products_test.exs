defmodule Persistence.Products.ProductsTest do
  use Persistence.DataCase, async: false

  import Persistence.Factory

  alias Persistence.Products.Products
  alias Persistence.Products.Schema.Product
  alias Persistence.Stores.Stores

  @moduletag :capture_log

  setup_all do
    product = build(:product)
    store = build(:store)

    {:ok, product: product, store: store}
  end

  describe "create/2" do
    test "should create a valid product with given a name_store and product params", %{
      product: product,
      store: store
    } do
      {:ok, store} = Stores.create(store)
      assert {:ok, %Product{}} = Products.create(store.name_store, product)
    end

    test "should return error when cod_product alredy been take", %{
      product: product,
      store: store
    } do
      {:ok, store} = Stores.create(store)
      Products.create(store.name_store, product)

      assert {
               :error,
               %Ecto.Changeset{}
             } = Products.create(store.name_store, product)
    end

    test "should return error when value under 1", %{product: product, store: store} do
      {:ok, store} = Stores.create(store)
      product = %{product | value: 0}

      assert {:error, changeset} = Products.create(store.name_store, product)

      assert %{value: ["must be greater than or equal to one"]} == errors_on(changeset)
    end

    test "should return error when quantity under 1", %{product: product, store: store} do
      {:ok, store} = Stores.create(store)
      product = %{product | quantity: 0}

      assert {:error, changeset} = Products.create(store.name_store, product)

      assert %{quantity: ["must be greater than or equal to one"]} == errors_on(changeset)
    end
  end

  describe "get_all_products_store/2" do
    test "should return all products from a store", %{product: product, store: store} do
      {:ok, store} = Stores.create(store)
      Enum.map(1..5, fn _x -> Products.create(store.name_store, product) end)

      assert [%Persistence.Products.Schema.Product{}] =
               Products.get_all_products_store(store.name_store, 1, 5)
    end

    test "should return a empty list when not find store", %{product: _product, store: store} do
      {:ok, store} = Stores.create(store)

      assert [] = Products.get_all_products_store(store.name_store, 1, 5)
    end
  end

  describe "get_all_products_store/1" do
    test "should return all products from a store", %{product: product, store: store} do
      {:ok, store} = Stores.create(store)
      Products.create(store.name_store, product)

      assert %Persistence.Products.Schema.Product{} =
               Products.get_by_cod_product(product.cod_product)
    end

    test "should return nil when not find product", %{product: product, store: store} do
      Stores.create(store)

      assert nil == Products.get_by_cod_product(product.cod_product)
    end
  end

  describe "update/2" do
    test "should a updated product", %{product: product, store: store} do
      {:ok, store} = Stores.create(store)
      Products.create(store.name_store, product)

      assert {:ok, %Persistence.Products.Schema.Product{description: "new_description"}} =
               Products.update(product.cod_product, %{description: "new_description"})
    end

    test "should return error when pass invalid attributes", %{product: product, store: store} do
      {:ok, store} = Stores.create(store)
      Products.create(store.name_store, product)

      assert {:error, changeset} =
               Products.update(product.cod_product, %{description: nil})

      assert %{description: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
