defmodule ClientWeb.Jsons.UserJson do
  def user(%{user: user}) do
    %{
      user: user.first_name <> " " <> user.last_name,
      cpf: user.cpf,
      email: user.email
    }
  end
end
