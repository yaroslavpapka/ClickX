# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :clickhouse_metrics,
  ecto_repos: [ClickhouseMetrics.Repo],
  generators: [timestamp_type: :utc_datetime]

config :clickhouse_metrics, Oban,
  repo: ClickhouseMetrics.Repo,
  queues: [clicks: 10],
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24},
    {Oban.Plugins.Cron,
    crontab: [
      {"*/1 * * * *", ClickhouseMetrics.MetricsInserterWorker}
    ]}
  ]

config :clickhouse_metrics,
  clickhouse: [
    username: System.get_env("CLICKHOUSE_USERNAME", "default"),
    password: System.get_env("CLICKHOUSE_PASSWORD", "password123"),
    database: System.get_env("CLICKHOUSE_DATABASE", "metrics"),
  ]

# Configures the endpoint
config :clickhouse_metrics, ClickhouseMetricsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ClickhouseMetricsWeb.ErrorHTML, json: ClickhouseMetricsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ClickhouseMetrics.PubSub,
  live_view: [signing_salt: "IXKqsQ/M"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :clickhouse_metrics, ClickhouseMetrics.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  clickhouse_metrics: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  clickhouse_metrics: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
