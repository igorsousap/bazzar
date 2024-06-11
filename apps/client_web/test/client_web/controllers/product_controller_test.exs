defmodule ClientWeb.ProductControllerTest do
  use ClientWeb.ConnCase, async: true

  import Persistence.Factory

  alias ClientWeb.Guardian
  alias Persistence.Users.Users
  alias Persistence.Products.Products
  alias Persistence.Stores.Stores

  setup %{conn: conn} do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Persistence.Repo)
    attrs_user = params_for(:user)
    {:ok, user} = Users.register_user(attrs_user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    attrs_store =
      params_for(:store)
      |> Map.put_new(:email, attrs_user.email)
      |> Map.put_new(:password, attrs_user.password)
      |> Map.put_new(:user_id, user.id)

    {:ok, store} = Stores.create(attrs_store)

    attrs_product =
      params_for(:product)
      |> Map.put_new(:email, attrs_user.email)
      |> Map.put_new(:password, attrs_user.password)

    Products.create(store.name_store, attrs_product)

    {:ok, attrs: attrs_product, conn: conn}
  end

  describe "create/2" do
    test "should return a product when passed valid params", %{
      conn: conn,
      attrs: attrs_product
    } do
      attrs_product = %{attrs_product | cod_product: "1234567891234"}

      response =
        conn
        |> post(~p"/api/product", attrs_product)
        |> json_response(:created)

      assert %{
               "cod_product" => attrs_product.cod_product,
               "description" => "dryfit t-shirt",
               "product_name" => "T-Shirt Adidas",
               "quantity" => 100,
               "size" => "xs",
               "value" => "105.99"
             } == response
    end

    test "should return a error when passed invalid params", %{
      conn: conn,
      attrs: attrs_product
    } do
      attrs_product = %{attrs_product | quantity: 0, value: 0}

      response =
        conn
        |> post(~p"/api/product", attrs_product)
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
      attrs: attrs_product
    } do
      response =
        conn
        |> get(
          ~p"/api/product/?email=#{attrs_product.email}&password=#{attrs_product.password}&page=1&page_size=2"
        )
        |> json_response(:ok)

      Enum.each(response, fn item ->
        assert is_map(item)
        assert Map.has_key?(item, "cod_product")
      end)
    end
  end

  describe "product_by_cod/2" do
    test "should return a product by a given code product", %{
      conn: conn,
      attrs: attrs_product
    } do
      response =
        conn
        |> get(
          ~p"/api/product/cod/#{attrs_product.cod_product}?email=#{attrs_product.email}&password=#{attrs_product.password}"
        )
        |> json_response(:ok)

      assert %{
               "cod_product" => attrs_product.cod_product,
               "description" => "dryfit t-shirt",
               "product_name" => "T-Shirt Adidas",
               "quantity" => 100,
               "size" => "xs",
               "value" => "105.99"
             } == response
    end

    test "should return error when product dosent exist", %{
      conn: conn,
      attrs: attrs_product
    } do
      response =
        conn
        |> get(
          ~p"/api/product/cod/1234567894615?email=#{attrs_product.email}&password=#{attrs_product.password}"
        )
        |> json_response(:not_found)

      assert %{"errors" => "Not Found"} == response
    end
  end

  describe "update/2" do
    test "should return a updated product with status 200 ", %{
      conn: conn,
      attrs: attrs_product
    } do
      params = %{
        "cod_product" => attrs_product.cod_product,
        "description" => "new_description",
        "email" => attrs_product.email,
        "password" => attrs_product.password
      }

      response =
        conn
        |> put(~p"/api/product", params)
        |> json_response(:ok)

      assert %{
               "cod_product" => attrs_product.cod_product,
               "description" => "new_description",
               "product_name" => "T-Shirt Adidas",
               "quantity" => 100,
               "size" => "xs",
               "value" => "105.99"
             } == response
    end

    test "should return error and status 404 when one of the params are incorrect ", %{
      conn: conn,
      attrs: attrs_product
    } do
      params = %{
        "cod_product" => attrs_product.cod_product,
        "description" => nil,
        "email" => attrs_product.email,
        "password" => attrs_product.password
      }

      response =
        conn
        |> put(~p"/api/product", params)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"description" => ["can't be blank"]}} == response
    end
  end
end
