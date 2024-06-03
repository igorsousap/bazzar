defmodule Persistence.Stores.Schema.Store do
  use Ecto.Schema

  import Ecto.Changeset

  alias Persistence.Users.Schema.User

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name_store: String.t(),
          description: Text.t(),
          adress: String.t(),
          neighborhood: String.t(),
          number: Integer.t(),
          cep: String.t(),
          cnpj: String.t(),
          phone: String.t(),
          user_id: Ecto.UUID.t()
        }

  @fields ~w(name_store description adress neighborhood number cep cnpj phone user_id)a

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "stores" do
    field(:name_store, :string)
    field(:description, :string)
    field(:adress, :string)
    field(:neighborhood, :string)
    field(:number, :integer)
    field(:cep, :string)
    field(:cnpj, :string)
    field(:phone, :string)
    field(:user_id, :binary_id)

    belongs_to(:users, User)

    timestamps()
  end

  @doc """
  Example
  iex> Persistence.Stores.Schema.Store.changeset(
          %{
          name_store: "IgorStore",
          description:  "Loja focada em vendas de roupa de academia",
          adress: "Rua Antonio Nunes",
          neighborhood: "Centro",
          number: 99,
          cep: "62010-140",
          cnpj: "07941071000138",
          phone: "889995955155"
           })
  """
  @spec changeset(:__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(store \\ %__MODULE__{}, attrs) do
    store
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint([:name_store], name: :store_name_index)
    |> unique_constraint([:cnpj], name: :store_cnpj_index)
    |> validate_cnpj()
    |> validate_format(:cep, ~r/^\d{5}-\d{3}$/, message: "invalid cep")
    |> validate_format(:phone, ~r/^\d{2}\d{4,5}\d{4}$/, message: "invalid phone")
  end

  defp validate_cnpj(changeset),
    do:
      Brcpfcnpj.Changeset.validate_cnpj(changeset, :cnpj,
        message: {"invalid cnpj", [index: :invalid]}
      )
end
