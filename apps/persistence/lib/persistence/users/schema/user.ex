defmodule Persistence.Users.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Persistence.Stores.Schema.Store

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          first_name: String.t(),
          last_name: String.t(),
          cpf: String.t(),
          email: String.t(),
          password: String.t(),
          hashed_password: String.t(),
          confirmed_at: NaiveDateTime.t()
        }

  @fields ~w(first_name last_name cpf email password confirmed_at)a
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :cpf, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string
    field :confirmed_at, :naive_datetime

    has_one(:stores, Store)

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates the changeset to validate a user to be inserted on the database
  Example
  iex> Persistence.Users.Schema.User.changeset(
          %{
          first_name: "Igor",
          last_name: "Sousa",
          cpf: Brcpfcnpj.cpf_generate(),
          email: "igorsousapinto140@gmail.com",
          password: "Igorsousa123@",
          confirmed_at: NaiveDateTime.local_now()
           })
  """
  @spec changeset(:__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, @fields)
    |> unique_constraint([:cpf], name: :users_cpf_index)
    |> unique_constraint([:email], name: :users_email_index)
    |> validate_email()
    |> validate_password()
  end

  @doc """
  Creates the changeset to validate a email only a email to be changed and inserted on the database
  Example
  iex> Persistence.Users.Schema.User.email_changeset(
          %Persistence.Users.Schema.User{
          first_name: "Igor",
          last_name: "Sousa",
          cpf: Brcpfcnpj.cpf_generate(),
          email: "igorsousapinto140@gmail.com",
          password: "Igorsousa123@",
          confirmed_at: NaiveDateTime.local_now()
           },
            %{email: "igorsousa@gmail.com"})
  """
  @spec email_changeset(%Persistence.Users.Schema.User{}, map()) :: Ecto.Changeset.t()
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  Creates the changeset to validate only a password to be changed and inserted on the database
  Example
  iex> Persistence.Users.Schema.User.password_changeset(
          %Persistence.Users.Schema.User{
          first_name: "Igor",
          last_name: "Sousa",
          cpf: Brcpfcnpj.cpf_generate(),
          email: "igorsousapinto140@gmail.com",
          password: "Igorsousa123@",
          confirmed_at: NaiveDateTime.local_now()
           },
            %{password: "igorsousA@123"})
  """
  @spec password_changeset(%Persistence.Users.Schema.User{}, map()) :: Ecto.Changeset.t()
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password()
  end

  @doc """
  Receive a password and a struct user to validated if the password passed is valid compared to hased password
  Example
  iex> Persistence.Users.Schema.User.password_changeset(
          %Persistence.Users.Schema.User{
          first_name: "Igor",
          last_name: "Sousa",
          cpf: Brcpfcnpj.cpf_generate(),
          email: "igorsousapinto140@gmail.com",
          password: "Igorsousa123@",
          confirmed_at: NaiveDateTime.local_now()
           },
            %{password: "igorsousa@123"})
  """
  def valid_password?(%Persistence.Users.Schema.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> validate_unique_email()
  end

  defp validate_unique_email(changeset) do
    changeset
    |> unsafe_validate_unique(:email, Persistence.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
      message: "at least one digit or punctuation character"
    )
    |> hash_password()
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      changeset
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end
end
