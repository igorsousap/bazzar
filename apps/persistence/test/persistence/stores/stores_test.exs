defmodule Persistence.Stores.StoresTest do
  use Persistence.DataCase, async: false

  import Persistence.Factory

  alias Persistence.Stores.Stores
  alias Persistence.Stores.Schema.Store
  alias Persistence.Users.Users

  @moduletag :capture_log

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    # User Create
    attrs_user = params_for(:user)
    {:ok, user} = Users.register_user(attrs_user)
    # Store Create
    attrs = params_for(:store, user_id: user.id)
    {:ok, store} = Stores.create(attrs)

    {:ok, store: store, user: user, attrs: attrs}
  end

  describe "create/2" do
    test "should create a valid store with given attributs", %{user: user} do
      store =
        params_for(:store, cnpj: Brcpfcnpj.cnpj_generate(), name_store: "New name store")
        |> Map.put(:user_id, user.id)

      assert {:ok, %Store{}} = Stores.create(store)
    end

    test "should return error when name_store alredy been take", %{user: user} do
      store =
        params_for(:store, cnpj: Brcpfcnpj.cnpj_generate())
        |> Map.put(:user_id, user.id)

      assert {:error, changeset} = Stores.create(store)
      assert %{name_store: ["has already been taken"]} == errors_on(changeset)
    end

    test "should return error when cnpj alredy been take", %{user: user, store: store} do
      store =
        params_for(:store, name_store: "New name store", cnpj: store.cnpj)
        |> Map.put(:user_id, user.id)

      assert {:error, changeset} = Stores.create(store)
      assert %{cnpj: ["has already been taken"]} == errors_on(changeset)
    end

    test "should return error when cep is invalid", %{user: user} do
      store =
        params_for(:store, name_store: "New name store", cep: "12345678")
        |> Map.put(:user_id, user.id)

      assert {:error, changeset} = Stores.create(store)
      assert %{cep: ["invalid cep"]} == errors_on(changeset)
    end

    test "should return error when phone is invalid", %{user: user} do
      store =
        params_for(:store, name_store: "New name store", phone: "889999999999")
        |> Map.put(:user_id, user.id)

      assert {:error, changeset} = Stores.create(store)
      assert %{phone: ["invalid phone"]} == errors_on(changeset)
    end

    test "should return error any field is empty", %{user: user} do
      store =
        params_for(:store, name_store: "New name store", phone: nil, description: nil)
        |> Map.put(:user_id, user.id)

      assert {:error, changeset} = Stores.create(store)
      assert %{phone: ["can't be blank"], description: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "get_store_by_name/1" do
    test "should return a store when given a name", %{store: store} do
      assert %Store{} = Stores.get_store_by_name(store.name_store)
    end

    test "should return nil when given a name with dosent exists" do
      assert {:error, :not_found} = Stores.get_store_by_name("test")
    end
  end

  describe "get_store_by_cnpj/1" do
    test "should return a store when given a cnpj", %{store: store} do
      assert %Store{} = Stores.get_store_by_cnpj(store.cnpj)
    end

    test "should return nil when given a name with dosent exists" do
      assert {:error, :not_found} = Stores.get_store_by_cnpj("123456789000123")
    end
  end

  describe "get_all_store/2" do
    test "should return all stores from database paginated" do
      assert [
               %Store{},
               %Store{}
             ] = Stores.get_all_stores(1, 2)
    end
  end

  describe "update_by_name_store/2" do
    test "should update store when pass valid attributes", %{store: store} do
      assert {:ok, %Store{}} =
               Stores.update_by_name_store(store.name_store, %{description: "new description"})
    end

    test "should return error when given a invalid attribute", %{store: store} do
      assert {:error, changeset} =
               Stores.update_by_name_store(store.name_store, %{description: nil})

      assert %{description: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
