defmodule Persistence.Stores.Stores do
  import Ecto.Query

  alias Persistence.Stores.Schema.Store
  alias Persistence.Repo

  @doc """
  Receive a user map and validate field and insert on the database
  Example
  iex> Persistence.Stores.Stores.create(
           %{
          name_store: "Test Store",
          description: "Store Description",
          adress: "Street Test",
          neighborhood: "City Center",
          number: 99,
          cep: "62010-140",
          cnpj: Brcpfcnpj.cnpj_generate(),
          phone: "88999999999"
           })
  """
  @spec create(map()) :: {:ok, Store.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    attrs
    |> Store.changeset()
    |> Repo.insert()
  end

  @doc """
  Receive a store name and return a store from given name
  Example
  iex> Persistence.Stores.Stores.get_store_by_name("Test Store")
  """
  @spec get_store_by_name(String.t()) :: Store.t() | {:error, :not_found}
  def get_store_by_name(name_store) do
    store_query =
      Store
      |> from()
      |> where([st], st.name_store == ^name_store)

    case Repo.one(store_query) do
      nil -> {:error, :not_found}
      store -> store
    end
  end

  @doc """
  Receive a cnpj from a store and return a store from given cnpj
  Example
  iex> Persistence.Stores.Stores.get_store_by_cnpj("07941071000138")
  """
  @spec get_store_by_cnpj(String.t()) :: Store.t() | {:error, :not_found}
  def get_store_by_cnpj(cnpj) do
    store_query =
      Store
      |> from()
      |> where([st], st.cnpj == ^cnpj)

    case Repo.one(store_query) do
      nil -> {:error, :not_found}
      store -> store
    end
  end

  @doc """
  Return all stores from database pagineted
  Example
  iex> Persistence.Stores.Stores.get_all_stores()
  """
  @spec get_all_stores(Integer.t(), Integer.t()) :: List.t() | []
  def get_all_stores(page, page_size) do
    Store
    |> from()
    |> order_by([st], desc: st.inserted_at)
    |> limit(^page_size)
    |> offset((^page - 1) * ^page_size)
    |> Repo.all()
  end

  @doc """
  Receive a store name and update a desired field passed in attributes
  Example
  iex> Persistence.Stores.Stores.update_by_name_store("Test Store", %{adress: "Street New Adress"})
  """
  @spec update_by_name_store(Store.t(), map()) :: {:ok, Store.t()} | {:error, Ecto.Changeset.t()}
  def update_by_name_store(name_store, attrs) do
    name_store
    |> get_store_by_name()
    |> Store.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Receive a user id and return a store owner from this user
  Example
  iex> Persistence.Stores.Stores.verify_id_store_from_user_id("Test Store", %{adress: "Street New Adress"})
  """
  @spec verify_id_store_from_user_id(Binary.id()) :: nil | {:ok, Store.t()}
  def verify_id_store_from_user_id(user_id) do
    store = Repo.get_by(Store, user_id: user_id)

    case store do
      nil -> nil
      _ -> {:ok, store}
    end
  end

  @doc """
  Receive a store id and return a store from database
  Example
  iex> Persistence.Stores.Stores.get_store_by_id("b6e76733-8e62-4dd0-8e30-f7749b4d0798")
  """
  @spec get_store_by_id(Binary.t()) :: {:ok, Store.t()} | {:error, Ecto.Changeset.t()}
  def get_store_by_id(id), do: Repo.get!(Store, id)

  @doc """
  Receive a store id and delete from database
  Example
  iex> Persistence.Stores.Stores.delete("b6e76733-8e62-4dd0-8e30-f7749b4d0798")
  """
  @spec delete(Binary.t()) :: {:ok, Store.t()} | {:error, Ecto.Changeset.t()}
  def delete(id), do: Repo.get!(Store, id) |> Repo.delete()
end
