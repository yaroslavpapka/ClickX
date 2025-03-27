defmodule ClickhouseMetrics.Repo do
  use Ecto.Repo,
    otp_app: :clickhouse_metrics,
    adapter: Ecto.Adapters.Postgres
end
