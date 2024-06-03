# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :client_web,
  generators: [context_app: false]

# Configures the endpoint
config :client_web, ClientWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ClientWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ClientWeb.PubSub,
  live_view: [signing_salt: "KGdPnPm1"]

# Configure Mix tasks and generators
config :persistence,
  ecto_repos: [Persistence.Repo]

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :client_web, ClientWeb.Guardian,
  issuer: "client_web",
  secret_key: "3WPh219VYn0kZchBNY+orU1Eg9mRtM5yLRwUWq+L/sNMEypznRWy4PmrgPe5aW8t"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
