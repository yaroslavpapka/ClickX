Clickhouse Metrics Tracker
Overview

The Clickhouse Metrics Tracker is a web application that tracks button clicks and stores metrics (IP, browser, device) in Clickhouse. All clicks are processed in the background using Oban, and data is visualized in real-time on a graph.

    Clickhouse for Analytics: Stores and analyzes click data.

    PostgreSQL: Stores metadata and application settings.

    Oban: Processes clicks in the background.

    Real-Time Graph: Displays click data over time, by IP, or by browser.

Getting Started
Installation

    Clone the repository:

git clone <repository_url>
cd clickhouse_metrics_tracker

Install dependencies:

mix deps.get
mix ecto.setup

Start the Phoenix server:

mix phx.server

Open your browser and go to:

    http://localhost:4000

Docker Compose

You can use the following docker-compose.yml to start PostgreSQL and Clickhouse:

version: "3"
services:
  postgres:
    image: postgres:latest
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: metrics_db
    ports:
      - "5432:5432"

  clickhouse:
    image: yandex/clickhouse-server:latest
    ports:
      - "8123:8123"
      - "9000:9000"
    volumes:
      - clickhouse-data:/var/lib/clickhouse

volumes:
  clickhouse-data:

Modules & Features
📊 Click Metrics Tracking

    Every button click is tracked with IP, browser, and device information.

    Data is stored in both PostgreSQL and Clickhouse for later analysis.

Clickhouse Table for Metrics:

CREATE TABLE metrics
(
    event_time DateTime,
    ip String,
    browser String,
    device String
) ENGINE = MergeTree()
ORDER BY event_time;

🛠️ Oban Background Processing

Each click is processed in the background using Oban to insert it into Clickhouse.
Oban Worker for Click Processing:

defmodule ClickhouseMetricsTracker.Workers.BatchInsert do
  use Oban.Worker, queue: :clickhouse

  @impl Oban.Worker
  def perform(_job) do
    # Logic for batch inserting clicks into Clickhouse
  end
end

📈 Click Graph

A graph is displayed on the webpage showing the number of clicks over time. You can filter the graph by:

    Date range

    Browser

    IP

📤 Batch Insert to Clickhouse

Every 60 seconds, we batch insert all the clicks processed by Oban into Clickhouse for efficient querying.
Deployment

For production deployment, refer to the official Phoenix Deployment Guide.
Technologies

    Elixir & Phoenix: For building the web application.

    Clickhouse: For storing and analyzing click data.

    PostgreSQL: For metadata and application settings.

    Oban: For background job processing.

    Chart.js: For displaying the click graph.

