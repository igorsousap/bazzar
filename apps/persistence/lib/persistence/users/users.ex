defmodule Persistence.Users.Users do
  import Ecto.Query

  alias Persistence.Repo
  alias Persistence.Users.Schema.{User, UserToken}

  @doc """
  Receive a map to register a user on the database
  ## Examples
      iex> Persistence.Users.Users.register_user(%{
          first_name: "First Name",
          last_name: "Last Name",
          cpf: Brcpfcnpj.cpf_generate(),
          email: "test@email.com",
          password: "Password123@",
          confirmed_at: NaiveDateTime.local_now()
           })
  """
  @spec register_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_user(attrs) do
    changeset =
      attrs
      |> User.changeset()

    case Repo.insert(changeset) do
      {:error, changeset} ->
        {:error, changeset}

      {:ok, user} ->
        register_token(user)
        {:ok, user}
    end
  end

  @doc """
  Receive a id and returns a user from database
  ## Examples
      iex> Persistence.Users.Users.get_user_by_id("c9112a6b-8782-43dc-a2a2-62829f028a88")
  """

  @spec get_user_by_id(Binary.t()) :: %Persistence.Users.Schema.User{} | nil
  def get_user_by_id(id), do: User |> Repo.get(id)

  @doc """
  Receive a email and password and return a user if is valid information
  ## Examples
      iex> Persistence.Users.Users.get_user_by_email_and_password("test@email.com", "Password123@")
  """
  @spec get_user_by_email_and_password(String.t(), String.t()) ::
          {:ok, %Persistence.Users.Schema.User{}} | nil
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)

    if User.valid_password?(user, password), do: {:ok, user}
  end

  @doc """
  Change the email from a given cpf user
  ## Examples
      iex> Persistence.Users.Users.change_user_email("94821895404", %{email: "test@email.com"})
  """
  @spec change_user_email(String.t(), map()) ::
          %Persistence.Users.Schema.User{}
          | {:error, :invalid_credentials}
          | {:error, :not_found}
          | {:error, Ecto.Changeset.t()}
  def change_user_email(cpf, attrs) do
    user =
      User
      |> from()
      |> where([us], us.cpf == ^cpf)

    case Repo.one(user) do
      nil ->
        {:error, :not_found}

      user ->
        case verify_token(user.id) do
          {:error, :invalid_credentials} ->
            {:error, :invalid_credentials}

          {:ok, %Persistence.Users.Schema.User{}} ->
            user
            |> User.email_changeset(attrs)
            |> Repo.update()
        end
    end
  end

  @doc """
  Change the password from a given cpf
  ## Examples
      iex> Persistence.Users.Users.change_user_password("94821895404", %{password: "NewPassword123@"})
  """
  @spec change_user_password(String.t(), map()) ::
          %Persistence.Users.Schema.User{}
          | {:error, :invalid_credentials}
          | {:error, :not_found}
          | {:error, Ecto.Changeset.t()}
  def change_user_password(cpf, attrs) do
    user =
      User
      |> from()
      |> where([us], us.cpf == ^cpf)

    case Repo.one(user) do
      nil ->
        {:error, :not_found}

      user ->
        case verify_token(user.id) do
          {:error, :invalid_credentials} ->
            {:error, :invalid_credentials}

          {:ok, %Persistence.Users.Schema.User{}} ->
            user
            |> User.password_changeset(attrs)
            |> Repo.update()
        end
    end
  end

  @doc """
  Generate a new token from a given email and password
  ## Examples
      iex> Persistence.Users.Users.new_token_for_user("test@email.com", "Password123@")
  """
  @spec new_token_for_user(String.t(), Binary.t()) ::
          {:ok, UserToken.t()} | {:error, Changeset.t()} | nil
  def new_token_for_user(email, password) when is_binary(email) and is_binary(password) do
    user =
      User
      |> from()
      |> where([us], us.email == ^email)
      |> Repo.one()

    case User.valid_password?(user, password) do
      false -> nil
      true -> register_token(user)
    end
  end

  @doc """
  Receive a id and verify if the token for this id is valid
  ## Examples
      iex> Persistence.Users.Users.verify_token("c9112a6b-8782-43dc-a2a2-62829f028a88")
  """
  @spec verify_token(Binary.t()) ::
          {:ok, %Persistence.Users.Schema.User{}} | {:error, :invalid_credentials}
  def verify_token(id) do
    with query_token <- UserToken.by_user_and_contexts_query(id),
         usertoken <- Repo.one(query_token),
         query_token <- UserToken.verify_session_token_query(usertoken.token),
         user <- Repo.one(query_token) do
      {:ok, user}
    else
      nil -> {:error, :invalid_credentials}
    end
  end

  defp register_token(%Persistence.Users.Schema.User{id: id} = user) do
    UserToken
    |> from()
    |> where([ut], ut.user_id == ^id)
    |> Repo.delete_all()

    id
    |> UserToken.build_session_token()
    |> UserToken.changeset()
    |> Repo.insert()

    {:ok, user}
  end
end
