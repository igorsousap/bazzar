defmodule Persistence.Users.Schema.UserToken do
  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias Persistence.Users.Schema.User
  alias Persistence.Users.Schema.UserToken

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          token: Binary.t(),
          context: String.t(),
          user_id: Ecto.UUID.t()
        }

  @rand_size 32
  @session_validity_in_days 1
  @fields ~w(token context user_id)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc """
  Creates the changeset to validate the insertion and usage of one token
    Example
    iex> Persistence.Users.Schema.UserToken.changeset(
      %{
      token: :crypto.strong_rand_bytes(32),
      context: "session",
      user_id: Ecto.UUID.autogenerate()
      })
  """
  @spec changeset(:__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(user_token \\ %__MODULE__{}, attrs) do
    user_token
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> assoc_constraint(:user)
  end

  @doc """
    Creates a token do be used for a user
    Example
    iex> Persistence.Users.Schema.UserToken.build_session_token("c9112a6b-8782-43dc-a2a2-62829f028a88")
  """
  @spec build_session_token(Binary.t()) :: map()
  def build_session_token(id) do
    token = :crypto.strong_rand_bytes(@rand_size)
    %{token: token, context: "session", user_id: id}
  end

  @doc """
    Query to verify if the token is valid to be used
    Example
    iex> Persistence.Users.Schema.UserToken.verify_session_token_query("2QÊ^  lsvk2oÑÝ3 ÔÈÁQ£+X*ÂõÂ<o 6N")
  """

  @spec verify_session_token_query(Binary.t()) :: Ecto.Query.t()
  def verify_session_token_query(token) do
    query =
      from token in by_token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    query
  end

  @doc """
    Query to find a token from a given id user
    Example
    iex> Persistence.Users.Schema.UserToken.by_user_and_contexts_query("c9112a6b-8782-43dc-a2a2-62829f028a88")
  """
  @spec by_user_and_contexts_query(Binary.t()) :: Ecto.Query.t()
  def by_user_and_contexts_query(id) do
    from t in UserToken, where: t.user_id == ^id
  end

  @doc """
    Query to find a user from a given token
    Example
    iex> Persistence.Users.Schema.UserToken.by_user_and_contexts_query("2QÊ^  lsvk2oÑÝ3 ÔÈÁQ£+X*ÂõÂ<o 6N")
  """
  @spec by_token_and_context_query(Binary.t(), String.t()) :: Ecto.Query.t()
  def by_token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end
end
