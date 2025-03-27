defmodule ClickhouseMetricsWeb.ClickLiveTest do
  use ClickhouseMetricsWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias ClickhouseMetrics.Repo
  alias ClickhouseMetrics.Click

  test "renders click button", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "button", "Click me")
  end

  test "handles click event and inserts record", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert Repo.aggregate(Click, :count, :id) == 0

    view
    |> element("button", "Click me")
    |> render_click()

  end

end
