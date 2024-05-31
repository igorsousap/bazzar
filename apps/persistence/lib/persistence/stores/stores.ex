defmodule Persistence.Stores.Stores do
  import Ecto.Query

  alias Persistence.Stores.Schema.Store
  alias Persistence.Repo

  @doc """
  Example
  iex> Persistence.Stores.Stores.create(
          %{
          name_store: "IgorStore",
          description:  "Loja focada em vendas de roupa de academia",
          adress: "Rua Antonio Nunes",
          neighborhood: "Centro",
          number: 99,
          cep: "62010-140",
          cnpj: "07941071000138",
          phone: "88999595515"
           })
  """
  @spec create(map()) :: {:ok, Store.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    attrs
    |> Store.changeset()
    |> Repo.insert()
  end

  @doc """
  Example
  iex> Persistence.Stores.Stores.get_store_by_name("IgorStore")
  """
  @spec get_store_by_name(String.t()) :: Store.t() | nil
  def get_store_by_name(name_store) do
    Store
    |> from()
    |> where([st], st.name_store == ^name_store)
    |> Repo.one()
  end

  @doc """
  Example
  iex> Persistence.Stores.Stores.get_store_by_cnpj("07941071000138")
  """
  @spec get_store_by_cnpj(String.t()) :: Store.t() | nil
  def get_store_by_cnpj(cnpj) do
    Store
    |> from()
    |> where([st], st.cnpj == ^cnpj)
    |> Repo.one()
  end

  @doc """
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
  Example
  iex> Persistence.Stores.Stores.update_by_name_store("IgorStore", %{adress: "Rua Casa Nova"})
  """
  @spec update_by_name_store(Store.t(), map()) :: {:ok, Store.t()} | {:error, Ecto.Changeset.t()}
  def update_by_name_store(name_store, attrs) do
    name_store
    |> get_store_by_name()
    |> Store.changeset(attrs)
    |> Repo.update()
  end

  def delete(id), do: Repo.get!(Store, id) |> Repo.delete()
end
