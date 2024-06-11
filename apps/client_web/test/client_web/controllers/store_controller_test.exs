defmodule ClientWeb.StoreControllerTest do
  use ClientWeb.ConnCase, async: true

  import Persistence.Factory

  alias ClientWeb.Guardian
  alias Persistence.Stores.Schema.Store
  alias Persistence.Stores.Stores
  alias Persistence.Users.Users

  @moduletag :capture_log

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

    Stores.create(attrs_store)

    {:ok, attrs: attrs_store, conn: conn, user: user}
  end

  describe "create/2" do
    test "should return 201 and store details", %{attrs: attrs_store, conn: conn} do
      attrs_store =
        %{
          attrs_store
          | cnpj: Brcpfcnpj.cnpj_generate(),
            name_store: "new_name_store"
        }

      response =
        conn
        |> post(~p"/api/store", attrs_store)
        |> json_response(:created)

      assert %{"cnpj" => attrs_store.cnpj, "name_store" => attrs_store.name_store} == response
    end

    test "should return 422 if passed invalid params", %{attrs: attrs_store, conn: conn} do
      attrs_store =
        %{
          attrs_store
          | cnpj: "123456789123"
        }

      response =
        conn
        |> post(~p"/api/store", attrs_store)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"cnpj" => ["invalid cnpj"]}} == response
    end

    test "should return 422 if required params not given", %{attrs: attrs_store, conn: conn} do
      attrs_store =
        %{
          attrs_store
          | cnpj: nil
        }

      response =
        conn
        |> post(~p"/api/store", attrs_store)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"cnpj" => ["can't be blank"]}} == response
    end
  end

  describe "get_store_by_name/2" do
    test "should return a store with status 200 ", %{attrs: attrs_store, conn: conn} do
      response =
        conn
        |> get(~p"/api/search/stores/#{attrs_store.name_store}")
        |> json_response(:ok)

      assert %{"cnpj" => attrs_store.cnpj, "name_store" => "teststore"} == response
    end

    test "should error and status 422 when not found ", %{conn: conn} do
      response =
        conn
        |> get(~p"/api/search/stores/RandomStore")
        |> json_response(:not_found)

      assert %{"errors" => "Not Found"} == response
    end
  end

  describe "get_store_by_cnpj/2" do
    test "should return a store with status 200 ", %{attrs: attrs_store, conn: conn} do
      response =
        conn
        |> get(~p"/api/search/stores/cnpj/#{attrs_store.cnpj}")
        |> json_response(:ok)

      assert %{"cnpj" => attrs_store.cnpj, "name_store" => "teststore"} == response
    end

    test "should error and status 422 when not found ", %{conn: conn} do
      response =
        conn
        |> get(~p"/api/search/stores/cnpj/1234567898784")
        |> json_response(:not_found)

      assert %{"errors" => "Not Found"} == response
    end
  end

  describe "update/2" do
    test "should return a updted store with status 200 ", %{attrs: attrs_store, conn: conn} do
      params = %{
        "name_store" => attrs_store.name_store,
        "description" => "new_description",
        "email" => attrs_store.email,
        "password" => attrs_store.password
      }

      response =
        conn
        |> put(~p"/api/store", params)
        |> json_response(:ok)

      assert %{"cnpj" => attrs_store.cnpj, "name_store" => "teststore"} == response
    end

    test "should error and status 404 when one of the params are incorrect ", %{
      attrs: attrs_store,
      conn: conn
    } do
      params = %{
        "name_store" => attrs_store.name_store,
        "description" => nil,
        "email" => attrs_store.email,
        "password" => attrs_store.password
      }

      response =
        conn
        |> put(~p"/api/store", params)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"description" => ["can't be blank"]}} == response
    end
  end

  describe "index/2" do
    test "should return all stores in a list with status 200 pagineted", %{
      conn: conn
    } do
      response =
        conn
        |> get(~p"/api/stores/?page=1&page_size=1")
        |> json_response(:ok)

      Enum.each(response, fn item ->
        assert is_map(item)
        assert Map.has_key?(item, "cnpj")
        assert Map.has_key?(item, "name_store")
      end)
    end

    test "should return error when not find any store", %{
      conn: conn
    } do
      Persistence.Repo.delete_all(Store)

      response =
        conn
        |> get(~p"/api/stores/?page=1&page_size=5")
        |> json_response(:ok)

      assert [] == response
    end
  end
end
