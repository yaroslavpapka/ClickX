import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :clickhouse_metrics, ClickhouseMetrics.Repo,
  database: System.get_env("POSTGRES_DATABASE", "clickhouse_metrics_test"),
  username: System.get_env("POSTGRES_USERNAME", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "secret"),
  hostname: System.get_env("POSTGRES_HOSTNAME", "localhost"),
  port: String.to_integer(System.get_env("POSTGRES_PORT", "5431")),
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :clickhouse_metrics, ClickhouseMetricsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "sHDJX9QigrmDnxPV0h1ozWVVopGKE3Y8Il6r/RGkp4TnNv5obGFRpEDF1PiobagM",
  server: false

# In test we don't send emails
config :clickhouse_metrics, ClickhouseMetrics.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
