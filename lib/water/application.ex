defmodule Water.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WaterWeb.Telemetry,
      Water.Repo,
      {DNSCluster, query: Application.get_env(:water, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Water.PubSub},
      Water.WaterMeterSimulator,
      # Start the Finch HTTP client for sending emails
      {Finch, name: Water.Finch},
      # Start a worker by calling: Water.Worker.start_link(arg)
      # {Water.Worker, arg},
      # Start to serve requests, typically the last entry
      WaterWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Water.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WaterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
