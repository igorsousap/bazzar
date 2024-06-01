defmodule ClientWeb.StoreControllerTest do
  use ClientWeb.ConnCase, async: false

  import Persistence.Factory

  alias Persistence.Stores.Schema.Store
  alias Persistence.Stores.Stores

  @moduletag :capture_log

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Persistence.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Persistence.Repo, {:shared, self()})

    store = build(:store)
    {:ok, store: store}
  end

  describe "create/2" do
    test "should return 201 and store details", %{store: store, conn: conn} do
      response =
        conn
        |> post(~p"/api/store", store)
        |> json_response(:created)

      assert %{"cnpj" => store.cnpj, "name_store" => "teststore"} == response
    end

    test "should return 422 if passed invalid params", %{store: _store, conn: conn} do
      store = build(:store, cnpj: "411567530001788", cep: "620101404")

      response =
        conn
        |> post(~p"/api/store", store)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"cep" => ["invalid cep"], "cnpj" => ["invalid cnpj"]}} == response
    end

    test "should return 422 if required params not given", %{store: _store, conn: conn} do
      store = build(:store, cnpj: nil, cep: nil)

      response =
        conn
        |> post(~p"/api/store", store)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"cep" => ["can't be blank"], "cnpj" => ["can't be blank"]}} ==
               response
    end
  end

  describe "index/2" do
    test "should return all stores in a list with status 200 pagineted", %{
      store: _store,
      conn: conn
    } do
      response =
        conn
        |> get(~p"/api/store/?page=1&page_size=5")
        |> json_response(:ok)

      Enum.each(response, fn item ->
        assert is_map(item)
        assert Map.has_key?(item, "cnpj")
        assert Map.has_key?(item, "name_store")
      end)
    end

    test "should return error when not find any store", %{
      store: _store,
      conn: conn
    } do
      Persistence.Repo.delete_all(Store)

      response =
        conn
        |> get(~p"/api/store/?page=1&page_size=5")
        |> json_response(:ok)

      assert [] == response
    end
  end

  describe "get_store_by_name/2" do
    test "should return a stores with status 200 ", %{
      store: store,
      conn: conn
    } do
      Stores.create(store)

      response =
        conn
        |> get(~p"/api/store-name/#{store.name_store}")
        |> json_response(:ok)

      assert %{"cnpj" => store.cnpj, "name_store" => "teststore"} == response
    end

    test "should error and status 422 when not found ", %{
      store: store,
      conn: conn
    } do
      response =
        conn
        |> get(~p"/api/store-name/#{store.name_store}")
        |> json_response(:not_found)

      assert %{"errors" => "Not Found"} == response
    end
  end

  describe "get_store_by_cnpj/2" do
    test "should return a store with status 200 ", %{
      store: store,
      conn: conn
    } do
      Stores.create(store)

      response =
        conn
        |> get(~p"/api/store-cnpj/#{store.cnpj}")
        |> json_response(:ok)

      assert %{"cnpj" => store.cnpj, "name_store" => "teststore"} == response
    end

    test "should error and status 422 when not found ", %{
      store: store,
      conn: conn
    } do
      response =
        conn
        |> get(~p"/api/store-cnpj/#{store.cnpj}")
        |> json_response(:not_found)

      assert %{"errors" => "Not Found"} == response
    end
  end

  describe "update/2" do
    test "should return a updted store with status 200 ", %{
      store: store,
      conn: conn
    } do
      Stores.create(store)

      params = %{
        "name_store" => store.name_store,
        "description" => "new_description"
      }

      response =
        conn
        |> put(~p"/api/store", params)
        |> json_response(:ok)

      assert %{"cnpj" => store.cnpj, "name_store" => "teststore"} == response
    end

    test "should error and status 404 when one of the params are incorrect ", %{
      store: store,
      conn: conn
    } do
      Stores.create(store)

      params = %{
        "name_store" => store.name_store,
        "description" => nil
      }

      response =
        conn
        |> put(~p"/api/store", params)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"description" => ["can't be blank"]}} == response
    end
  end
end
