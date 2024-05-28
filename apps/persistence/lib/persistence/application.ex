defmodule Persistence.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Persistence.Repo,
      {DNSCluster, query: Application.get_env(:persistence, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Persistence.PubSub}
      # Start a worker by calling: Persistence.Worker.start_link(arg)
      # {Persistence.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Persistence.Supervisor)
  end
end
