defmodule ClientWeb.SessionController do
  use ClientWeb, :controller

  alias ClientWeb.Guardian
  alias Persistence.Users.Users

  def create(conn, params) do
    case Users.get_user_by_email_and_password(params["email"], params["password"]) do
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})

      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        json(conn, %{token: token})
    end
  end
end
