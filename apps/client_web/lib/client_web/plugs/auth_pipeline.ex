defmodule ClientWeb.Plugs.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :client_web,
    module: ClientWeb.Guardian,
    error_handler: ClientWeb.Plugs.ErrorHandler

  plug Guardian.Plug.VerifyHeader, schema: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
