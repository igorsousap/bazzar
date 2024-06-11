defmodule Persistence.Products.ProductsTest do
  use Persistence.DataCase, async: false

  import Persistence.Factory

  alias Persistence.Products.Products
  alias Persistence.Products.Schema.Product
  alias Persistence.Stores.Stores
  alias Persistence.Users.Users

  @moduletag :capture_log

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    # User Create
    attrs_user = params_for(:user)
    {:ok, user} = Users.register_user(attrs_user)
    # Store Create
    attrs_store = params_for(:store, user_id: user.id)
    {:ok, store} = Stores.create(attrs_store)
    # Product Create
    attrs_product = params_for(:product, id_store: store.id)
    {:ok, product} = Products.create(store.name_store, attrs_product)

    {:ok, product: product, store: store}
  end

  describe "create/2" do
    test "should create a valid product with given a name_store and product params", %{
      store: store
    } do
      product = params_for(:product)
      assert {:ok, %Product{}} = Products.create(store.name_store, product)
    end

    test "should return error when cod_product alredy been take", %{
      product: product,
      store: store
    } do
      product = params_for(:product, cod_product: product.cod_product)

      assert {:error, changeset} = Products.create(store.name_store, product)

      assert %{cod_product: ["has already been taken"]} == errors_on(changeset)
    end

    test "should return error when value under 1", %{store: store} do
      product = params_for(:product, value: 0)

      assert {:error, changeset} = Products.create(store.name_store, product)

      assert %{value: ["must be greater than or equal to one"]} == errors_on(changeset)
    end

    test "should return error when quantity under 1", %{store: store} do
      product = params_for(:product, quantity: 0)

      assert {:error, changeset} = Products.create(store.name_store, product)

      assert %{quantity: ["must be greater than or equal to one"]} == errors_on(changeset)
    end
  end

  describe "get_all_products_store/2" do
    test "should return all products from a store", %{store: store} do
      assert [%Persistence.Products.Schema.Product{}] =
               Products.get_all_products_store(store.name_store, 1, 1)
    end

    test "should return a error when not find store" do
      assert {:error, :not_found} = Products.get_all_products_store("Non existing store", 1, 5)
    end
  end

  describe "get_by_cod_product/1" do
    test "should return a product from a given code product", %{product: product} do
      assert %Persistence.Products.Schema.Product{} =
               Products.get_by_cod_product(product.cod_product)
    end

    test "should return nil when not find product" do
      assert {:error, :not_found} = Products.get_by_cod_product("1234567891234")
    end
  end

  describe "update/2" do
    test "should a updated product", %{product: product} do
      assert {:ok, %Persistence.Products.Schema.Product{description: "new_description"}} =
               Products.update(product.cod_product, %{description: "new_description"})
    end

    test "should return error when pass invalid attributes", %{product: product} do
      assert {:error, changeset} =
               Products.update(product.cod_product, %{description: nil})

      assert %{description: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
