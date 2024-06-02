defmodule Persistence.Users.Users do
  import Ecto.Query

  alias Persistence.Repo
  alias Persistence.Users.Schema.{User, UserToken}

  @doc """
  ## Examples

      iex> Persistence.Users.Users.register_user(%{
          first_name: "Igor",
          last_name: "Sousa",
          cpf: Brcpfcnpj.cpf_generate(),
          email: "igorsousapinto140@gmail.com",
          password: "Igorsousa123@",
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
  ## Examples

      iex> Persistence.Users.Users.get_user_by_email_and_password("igorsousapinto140@gmail.com", "Igorsousa123@")
  """
  @spec get_user_by_email_and_password(String.t(), String.t()) ::
          %Persistence.Users.Schema.User{} | nil
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  ## Examples

      iex> Persistence.Users.Users.change_user_email("94821895404", %{email: "igorsousa@gmail.com"})
  """
  @spec change_user_email(String.t(), map()) :: %Persistence.Users.Schema.User{} | nil
  def change_user_email(cpf, attrs) do
    user =
      User
      |> from()
      |> where([us], us.cpf == ^cpf)
      |> Repo.one()

    case verify_token(user.id) do
      nil ->
        nil

      %Persistence.Users.Schema.User{} ->
        user
        |> User.email_changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  ## Examples

      iex> Persistence.Users.Users.change_user_email("94821895404", %{password: "NewPassword123@"})
  """
  @spec change_user_password(String.t(), map()) :: %Persistence.Users.Schema.User{} | nil
  def change_user_password(cpf, attrs) do
    user =
      User
      |> from()
      |> where([us], us.cpf == ^cpf)
      |> Repo.one()

    case verify_token(user.id) do
      nil ->
        nil

      %Persistence.Users.Schema.User{} ->
        user
        |> User.password_changeset(attrs)
        |> Repo.update()
    end
  end

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

  defp verify_token(id) do
    with query_token <- UserToken.by_user_and_contexts_query(id),
         usertoken <- Repo.one(query_token),
         query_token <- UserToken.verify_session_token_query(usertoken.token),
         user <- Repo.one(query_token) do
      user
    end
  end
end
