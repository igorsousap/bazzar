defmodule ClientWeb.ProductControllerTest do
  use ClientWeb.ConnCase, async: false

  import Persistence.Factory

  alias Persistence.Products.Schema.Product
  alias Persistence.Products.Products
  alias Persistence.Stores.Stores

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Persistence.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Persistence.Repo, {:shared, self()})
    store = build(:store)
    product = build(:product, name_store: store.name_store)
    {:ok, product: product, store: store}
  end

  describe "create/2" do
    test "should return a product when passed valid params", %{
      conn: conn,
      product: product,
      store: store
    } do
      Stores.create(store)

      response =
        conn
        |> post(~p"/api/product", product)
        |> json_response(:created)

      assert %{
               "cod_product" => "7898357411232",
               "description" => "dryfit t-shirt",
               "product_name" => "T-Shirt Adidas",
               "quantity" => 100,
               "size" => "xs",
               "value" => "105.99"
             } == response
    end

    test "should return a error when passed invalid params", %{
      conn: conn,
      product: product,
      store: store
    } do
      Stores.create(store)

      product = %{product | quantity: 0, value: 0}

      response =
        conn
        |> post(~p"/api/product", product)
        |> json_response(:unprocessable_entity)

      assert %{
               "errors" => %{
                 "quantity" => ["must be greater than or equal to one"],
                 "value" => ["must be greater than or equal to one"]
               }
             } == response
    end
  end

  describe "products_by_store/2" do
    test "should get all products from a given store", %{
      conn: conn,
      product: product,
      store: store
    } do
      Stores.create(store)
      Products.create(store.name_store, product)

      response =
        conn
        |> get(~p"/api/product/#{store.name_store}?page=1&page_size=2")
        |> json_response(:ok)

      Enum.each(response, fn item ->
        assert is_map(item)
        assert Map.has_key?(item, "cod_product")
      end)
    end

    test "should return a empty list when store dosent have products", %{
      conn: conn,
      product: product,
      store: store
    } do
      Stores.create(store)

      response =
        conn
        |> get(~p"/api/product/#{store.name_store}?page=1&page_size=2")
        |> json_response(:ok)

      assert [] == response
    end
  end

  describe "product_by_cod/2" do
    test "should return a product by a given code product", %{
      conn: conn,
      product: product,
      store: store
    } do
      Stores.create(store)
      Products.create(store.name_store, product)

      response =
        conn
        |> get(~p"/api/product/cod/#{product.cod_product}")
        |> json_response(:ok)

      assert %{
               "cod_product" => "7898357411232",
               "description" => "dryfit t-shirt",
               "product_name" => "T-Shirt Adidas",
               "quantity" => 100,
               "size" => "xs",
               "value" => "105.99"
             } == response
    end

    test "should return error when product dosent exist", %{
      conn: conn,
      product: product,
      store: store
    } do
      Stores.create(store)

      response =
        conn
        |> get(~p"/api/product/cod/#{product.cod_product}")
        |> json_response(:not_found)

      assert %{"errors" => "Not Found"} == response
    end
  end

  describe "update/2" do
    test "should return a updated product with status 200 ", %{
      product: product,
      conn: conn,
      store: store
    } do
      Stores.create(store)
      Products.create(store.name_store, product)

      params = %{
        "cod_product" => product.cod_product,
        "description" => "new_description"
      }

      response =
        conn
        |> put(~p"/api/product", params)
        |> json_response(:ok)

      assert %{
               "cod_product" => "7898357411232",
               "description" => "new_description",
               "product_name" => "T-Shirt Adidas",
               "quantity" => 100,
               "size" => "xs",
               "value" => "105.99"
             } == response
    end

    test "should return error and status 404 when one of the params are incorrect ", %{
      product: product,
      store: store,
      conn: conn
    } do
      Stores.create(store)
      Products.create(store.name_store, product)

      params = %{
        "cod_product" => product.cod_product,
        "description" => nil
      }

      response =
        conn
        |> put(~p"/api/product", params)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"description" => ["can't be blank"]}} == response
    end
  end
end
