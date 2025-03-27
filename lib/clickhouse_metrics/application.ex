defmodule ClickhouseMetrics.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ClickhouseMetricsWeb.Telemetry,
      ClickhouseMetrics.Repo,
      {DNSCluster, query: Application.get_env(:clickhouse_metrics, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ClickhouseMetrics.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ClickhouseMetrics.Finch},
      # Start a worker by calling: ClickhouseMetrics.Worker.start_link(arg)
      # {ClickhouseMetrics.Worker, arg},
      # Start to serve requests, typically the last entry
      ClickhouseMetricsWeb.Endpoint,
      {Oban, Application.fetch_env!(:clickhouse_metrics, Oban)}
    ]
    ClickhouseMetrics.create_metrics_table()
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ClickhouseMetrics.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ClickhouseMetricsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
