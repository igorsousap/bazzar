defmodule Persistence.Products.Schema.Product do
  use Ecto.Schema

  import Ecto.Changeset

  alias Persistence.Stores.Schema.Store

  @type size_types :: :xs | :s | :m | :l | :xl | :xxl | :xxxl
  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          product_name: String.t(),
          cod_product: String.t(),
          id_store: Ecto.UUID.t(),
          description: Text.t(),
          size: size_types(),
          value: Decimal.t(),
          quantity: Integer.t(),
          picture: String.t()
        }

  @fields ~w(product_name description cod_product id_store size value quantity picture)a
  @size_types ~w(xs s m l xl xxl xxxl)a
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field(:product_name, :string)
    field(:description, :string)
    field(:cod_product, :string)
    field(:id_store, :binary_id)
    field(:size, Ecto.Enum, values: @size_types)
    field(:value, :decimal)
    field(:quantity, :integer)
    field(:picture, :string)

    has_one(:stores, Store)

    timestamps()
  end

  @doc """
  Example
  iex> Persistence.Products.Schema.Product.changeset(
          %{
          product_name: "Blusa adidas",
          description: "regata azul com simbolo branco",
          cod_product: "7898357411232",
          id_store: Ecto.UUID.generate(),
          size: "xs",
          value: 105.99,
          quantity: 100,
          picture: "www.linkimage.com"
           })
  """
  @spec changeset(:__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(product \\ %__MODULE__{}, attrs) do
    product
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint([:cod_product], name: :cod_product_index)
    |> foreign_key_constraint(:id_store, name: :products_id_store_fkey)
    |> validate_value()
    |> validate_quantity()
  end

  def validate_value(changeset) do
    validate_number(changeset, :value,
      greater_than_or_equal_to: 1,
      message: "must be greater than or equal to one"
    )
  end

  def validate_quantity(changeset) do
    validate_number(changeset, :quantity,
      greater_than_or_equal_to: 1,
      message: "must be greater than or equal to one"
    )
  end
end
