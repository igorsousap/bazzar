defmodule ClientWeb.Guardian do
  use Guardian, otp_app: :client_web

  alias Persistence.Users.Users

  def subject_for_token(resource, _claims), do: {:ok, to_string(resource.id)}

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Users.get_user_by_id(id)
    {:ok, resource}
  end
end
