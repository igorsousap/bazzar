import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :client_web, ClientWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "SrqLhVhoYiK1JljQ+EbkVBKIxxr0S/aHpnC6pEbg2rmBOa2kv3E2kIh+P2YAkeJB",
  server: false

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :persistence, Persistence.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "persistence_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2
