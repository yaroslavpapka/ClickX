defmodule ClickhouseMetrics do
  @clickhouse_opts Application.get_env(:clickhouse_metrics, :clickhouse)

  def create_metrics_table do
    query = """
    CREATE TABLE IF NOT EXISTS metrics (
      id UUID DEFAULT generateUUIDv4(),
      ip String,
      user_agent String,
      browser String,
      device String,
      timestamp DateTime DEFAULT now()
    ) ENGINE = MergeTree()
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY timestamp
    """

    {:ok, pid} = Ch.start_link(@clickhouse_opts)

    case Ch.query(pid, query) do
      {:ok, _} -> IO.puts("Table created successfully")
      {:error, error} -> IO.puts("Error creating table: #{inspect(error)}")
    end
  end

  def insert_metrics([]), do: :ok

  def insert_metrics(clicks) do
    sanitize = fn value -> String.replace(value, "'", "''") end

    query = """
    INSERT INTO metrics (id, ip, user_agent, browser, device, timestamp)
    VALUES #{Enum.map_join(clicks, ",", fn %{inserted_at: ts, ip: ip, user_agent: ua, browser: br, device: dv} -> "(generateUUIDv4(), '#{sanitize.(ip)}', '#{sanitize.(ua)}', '#{sanitize.(br)}', '#{sanitize.(dv)}', '#{NaiveDateTime.to_string(NaiveDateTime.truncate(ts, :second)) |> String.replace("T", " ")}')" end)}
    """

    with {:ok, pid} <- Ch.start_link(@clickhouse_opts),
         {:ok, _} <- Ch.query(pid, query) do
      IO.puts("Inserted #{length(clicks)} clicks into ClickHouse")
    else
      {:error, error} -> IO.puts("Error inserting clicks: #{inspect(error)}")
    end
  end

  def list_clicks(browser_filter \\ nil, ip_filter \\ nil, device_filter \\ nil) do
    {:ok, conn} = Ch.start_link(@clickhouse_opts)

    where_clause = build_where_clause(browser_filter, ip_filter, device_filter)

    query = """
    SELECT
      toString(timestamp), ip, browser, device, user_agent
    FROM metrics
    #{where_clause}
    ORDER BY timestamp
    """

    execute_query(conn, query)
  end

  def unique_values(column) do
    {:ok, conn} = Ch.start_link(@clickhouse_opts)
    query = "SELECT DISTINCT #{column} FROM metrics"

    case Ch.query(conn, query) do
      {:ok, %{rows: rows}} -> Enum.map(rows, &hd/1)
      {:error, _reason} -> []
    end
  end

  defp build_where_clause(nil, nil, nil), do: ""

  defp build_where_clause(browser_filter, ip_filter, device_filter) do
    filters =
      [build_filter("browser", browser_filter), build_filter("ip", ip_filter), build_filter("device", device_filter)]
      |> Enum.filter(& &1)
      |> Enum.join(" AND ")

    "WHERE #{filters}"
  end

  defp build_filter(_field, nil), do: nil
  defp build_filter(_field, ""), do: nil

  defp build_filter(field, value) do
    "#{field} = '#{sanitize(value)}'"
  end

  defp sanitize(value), do: String.replace(value, "'", "''")

  defp execute_query(conn, query) do
    case Ch.query(conn, query) do
      {:ok, %{rows: rows}} -> process_rows(rows)
      {:error, reason} -> handle_error(reason)
    end
  end

  defp process_rows(rows) do
    Enum.map(rows, fn [timestamp, ip, browser, device, _user_agent] ->
      formatted_timestamp = timestamp |> String.replace(" ", "T")
      naive_dt = NaiveDateTime.from_iso8601!(formatted_timestamp)

      %{
        timestamp: naive_dt,
        date: Date.to_string(naive_dt |> NaiveDateTime.to_date()),
        ip: ip,
        browser: browser,
        device: device
      }
    end)
  end

  defp handle_error(reason) do
    IO.inspect(reason, label: "ClickHouse Query Error")
    []
  end

  def delete_all_metrics do
    query = "TRUNCATE TABLE metrics;"

    with {:ok, pid} <- Ch.start_link(@clickhouse_opts),
         {:ok, _} <- Ch.query(pid, query) do
      IO.puts("All metrics deleted successfully")
    else
      {:error, error} -> IO.puts("Error deleting metrics: #{inspect(error)}")
    end
  end
end
