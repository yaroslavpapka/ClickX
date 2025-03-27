defmodule ClickhouseMetricsTest do
  use ExUnit.Case
  alias ClickhouseMetrics

  setup_all do
    ClickhouseMetrics.create_metrics_table()
    :ok
  end

  setup do
    ClickhouseMetrics.delete_all_metrics()
    :ok
  end

  test "create_metrics_table does not raise errors" do
    assert ClickhouseMetrics.create_metrics_table() == :ok
  end

  test "insert_metrics with empty list does nothing" do
    assert ClickhouseMetrics.insert_metrics([]) == :ok
  end

  test "insert_metrics correctly adds a single entry" do
    click = [%{
      inserted_at: NaiveDateTime.utc_now(),
      ip: "192.168.0.1",
      user_agent: "Mozilla/5.0",
      browser: "Firefox",
      device: "Desktop"
    }]
    ClickhouseMetrics.insert_metrics(click)
    assert length(ClickhouseMetrics.list_clicks(nil, nil)) == 1
  end

  test "insert_metrics adds multiple entries" do
    clicks = for i <- 1..3 do
      %{
        inserted_at: NaiveDateTime.utc_now(),
        ip: "192.168.0.#{i}",
        user_agent: "Mozilla/5.0",
        browser: "Firefox",
        device: "Desktop"
      }
    end
    ClickhouseMetrics.insert_metrics(clicks)
    assert length(ClickhouseMetrics.list_clicks(nil, nil)) == 3
  end

  test "list_clicks filters by browser" do
    ClickhouseMetrics.insert_metrics([
      %{inserted_at: NaiveDateTime.utc_now(), ip: "1.1.1.1", user_agent: "UA1", browser: "Chrome", device: "Mobile"},
      %{inserted_at: NaiveDateTime.utc_now(), ip: "2.2.2.2", user_agent: "UA2", browser: "Firefox", device: "Desktop"}
    ])

    assert length(ClickhouseMetrics.list_clicks("Chrome", nil)) == 1
    assert length(ClickhouseMetrics.list_clicks("Firefox", nil)) == 1
  end

  test "list_clicks filters by IP" do
    ClickhouseMetrics.insert_metrics([
      %{inserted_at: NaiveDateTime.utc_now(), ip: "10.0.0.1", user_agent: "UA1", browser: "Chrome", device: "Mobile"},
      %{inserted_at: NaiveDateTime.utc_now(), ip: "10.0.0.2", user_agent: "UA2", browser: "Firefox", device: "Desktop"}
    ])

    assert length(ClickhouseMetrics.list_clicks(nil, "10.0.0.1")) == 1
    assert length(ClickhouseMetrics.list_clicks(nil, "10.0.0.2")) == 1
  end

  test "list_clicks filters by browser and IP combination" do
    ClickhouseMetrics.insert_metrics([
      %{inserted_at: NaiveDateTime.utc_now(), ip: "3.3.3.3", user_agent: "UA1", browser: "Chrome", device: "Mobile"},
      %{inserted_at: NaiveDateTime.utc_now(), ip: "4.4.4.4", user_agent: "UA2", browser: "Chrome", device: "Desktop"}
    ])

    assert length(ClickhouseMetrics.list_clicks("Chrome", "3.3.3.3")) == 1
    assert length(ClickhouseMetrics.list_clicks("Chrome", "4.4.4.4")) == 1
  end

  test "unique_values returns unique browsers" do
    ClickhouseMetrics.insert_metrics([
      %{inserted_at: NaiveDateTime.utc_now(), ip: "5.5.5.5", user_agent: "UA1", browser: "Safari", device: "Tablet"},
      %{inserted_at: NaiveDateTime.utc_now(), ip: "6.6.6.6", user_agent: "UA2", browser: "Safari", device: "Tablet"}
    ])
    assert ClickhouseMetrics.unique_values("browser") == ["Safari"]
  end

  test "delete_all_metrics clears the table" do
    ClickhouseMetrics.insert_metrics([
      %{inserted_at: NaiveDateTime.utc_now(), ip: "7.7.7.7", user_agent: "UA1", browser: "Edge", device: "Laptop"}
    ])
    ClickhouseMetrics.delete_all_metrics()
    assert ClickhouseMetrics.list_clicks(nil, nil) == []
  end
end
