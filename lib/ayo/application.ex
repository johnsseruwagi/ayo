defmodule Ayo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AyoWeb.Telemetry,
      Ayo.Repo,
      {DNSCluster, query: Application.get_env(:ayo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ayo.PubSub},
      # Start a worker by calling: Ayo.Worker.start_link(arg)
      # {Ayo.Worker, arg},
      # Start to serve requests, typically the last entry
      AyoWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :ayo]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ayo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AyoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
