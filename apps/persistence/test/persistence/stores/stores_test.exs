defmodule Persistence.Stores.StoresTest do
  use Persistence.DataCase, async: false

  import Persistence.Factory

  alias Persistence.Stores.Stores
  alias Persistence.Stores.Schema.Store

  @moduletag :capture_log

  setup_all do
    store = build(:store)
    {:ok, store: store}
  end

  describe "create/2" do
    test "should create a valid store with given attributs", %{store: store} do
      assert {:ok, %Store{}} = Stores.create(store)
    end

    test "should return error when name_store alredy been take", %{store: store} do
      assert {:ok, %Store{}} = Stores.create(store)
      assert {:error, changeset} = Stores.create(store)
      assert %{name_store: ["has already been taken"]} == errors_on(changeset)
    end

    test "should return error when cnpj alredy been take", %{store: store} do
      assert {:ok, %Store{}} = Stores.create(store)
      store_error = build(:store, name_store: "test2store", cnpj: store.cnpj)
      assert {:error, changeset} = Stores.create(store_error)
      assert %{cnpj: ["has already been taken"]} == errors_on(changeset)
    end

    test "should return error when cep is invalid", %{store: store} do
      store_cep = %{store | cep: "12345678"}
      assert {:error, changeset} = Stores.create(store_cep)
      assert %{cep: ["invalid cep"]} == errors_on(changeset)
    end

    test "should return error when phone is invalid", %{store: store} do
      store_cep = %{store | phone: "889999999999"}
      assert {:error, changeset} = Stores.create(store_cep)
      assert %{phone: ["invalid phone"]} == errors_on(changeset)
    end

    test "should return error any field is empty", %{store: store} do
      store_cep = %{store | phone: nil, description: nil}
      assert {:error, changeset} = Stores.create(store_cep)
      assert %{phone: ["can't be blank"], description: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "get_store_by_name/1" do
    test "should return a store when given a name", %{store: store} do
      Stores.create(store)
      assert %Store{} = Stores.get_store_by_name(store.name_store)
    end

    test "should return nil when given a name with dosent exists", %{store: _store} do
      assert nil == Stores.get_store_by_name("test")
    end
  end

  describe "get_store_by_cnpj/1" do
    test "should return a store when given a cnpj", %{store: store} do
      Stores.create(store)
      assert %Store{} = Stores.get_store_by_cnpj(store.cnpj)
    end

    test "should return nil when given a name with dosent exists", %{store: _store} do
      assert nil == Stores.get_store_by_cnpj("123456789000123")
    end
  end

  describe "get_all_store/2" do
    test "should return all stores from database paginated", %{store: store} do
      Enum.map(1..3, fn _x -> Stores.create(store) end)

      assert [
               %Store{},
               %Store{}
             ] = Stores.get_all_stores(1, 5)
    end
  end

  describe "pdate_by_name_store/2" do
    test "should update store when pass valid attributes", %{store: store} do
      Stores.create(store)

      assert {:ok, %Store{}} =
               Stores.update_by_name_store(store.name_store, %{description: "new description"})
    end

    test "should return error when given a invalid attribute", %{store: store} do
      Stores.create(store)

      assert {:error, changeset} =
               Stores.update_by_name_store(store.name_store, %{description: nil})

      assert %{description: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
