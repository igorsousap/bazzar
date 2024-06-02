defmodule ClientWeb.UserController do
  use ClientWeb, :controller

  require Logger

  alias Persistence.Users.Users

  action_fallback(ClientWeb.FallbackController)

  plug :put_view, json: ClientWeb.Jsons.UserJson

  def register_user(conn, params) do
    with {:ok, params} <- build_user_params(params),
         {:ok, user} <- Users.register_user(params) do
      conn
      |> put_status(:created)
      |> render(:user, layout: false, user: user)
    else
      error ->
        Logger.error(
          "Could not create user with attributes #{inspect(params)}. Error: #{inspect(error)}"
        )

        IO.inspect(error)

        error
    end
  end

  def get_user(conn, params) do
    case Users.get_user_by_email_and_password(params["email"], params["password"]) do
      nil ->
        Logger.error("Could not find user with attributes #{inspect(params)}.")

        {:error, :not_found}

      user ->
        conn
        |> put_status(:ok)
        |> render(:user, layout: false, user: user)
    end
  end

  def change_email_or_password(conn, params) do
    case params do
      %{"password" => password} ->
        case Users.change_user_password(params["cpf"], %{"password" => password}) do
          nil ->
            Logger.error("Could not find user with attributes #{inspect(params)}.")

            {:error, :not_found}

          {:ok, user} ->
            conn
            |> put_status(:ok)
            |> render(:user, layout: false, user: user)
        end

      %{"email" => email} ->
        case Users.change_user_email(params["cpf"], %{"email" => email}) do
          nil ->
            Logger.error("Could not find user with attributes #{inspect(params)}.")

            {:error, :not_found}

          {:ok, user} ->
            conn
            |> put_status(:ok)
            |> render(:user, layout: false, user: user)
        end
    end
  end

  def generate_new_token(conn, params) do
    case Users.new_token_for_user(params["email"], params["password"]) do
      nil ->
        Logger.error("Could not find user with attributes #{inspect(params)}.")

        {:error, :not_found}

      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> render(:user, layout: false, user: user)
    end
  end

  defp build_user_params(params) do
    params = %{
      first_name: params["first_name"],
      last_name: params["last_name"],
      cpf: params["cpf"],
      email: params["email"],
      password: params["password"],
      confirmed_at: NaiveDateTime.local_now()
    }

    {:ok, params}
  end
end
