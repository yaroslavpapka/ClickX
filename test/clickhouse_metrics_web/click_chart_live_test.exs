defmodule ClickhouseMetricsWeb.ClickChartLiveTest do
  use ClickhouseMetricsWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "mount assigns default values", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/click_chart")

    assert render(view) =~ "By Browser"
    assert render(view) =~ "All Browsers"
    assert render(view) =~ "All IPs"
    assert render(view) =~ "svg"
  end

  test "changing chart type updates assigns", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/click_chart")

    view |> element("form[phx-change=\"change_chart\"]") |> render_change(%{"chart" => "ip"})

    assert render(view) =~ "By IP"
    assert render(view) =~ "svg"
  end

  test "filtering updates assigns and chart_svg", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/click_chart")

    view |> element("form[phx-change=\"filter\"]") |> render_change(%{"browser" => "Chrome", "ip" => "192.168.1.1"})

    assert render(view) =~ "Chrome"
    assert render(view) =~ "192.168.1.1"
    assert render(view) =~ "svg"
  end

  test "filtering with empty values resets selection", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/click_chart")

    view |> element("form[phx-change=\"filter\"]") |> render_change(%{"browser" => "", "ip" => ""})

    assert render(view) =~ "All Browsers"
    assert render(view) =~ "All IPs"
    assert render(view) =~ "svg"
  end

  test "filtering with only browser updates chart", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/click_chart")

    view |> element("form[phx-change=\"filter\"]") |> render_change(%{"browser" => "Firefox", "ip" => ""})

    assert render(view) =~ "192.168.1.1"
    assert render(view) =~ "All IPs"
    assert render(view) =~ "svg"
  end

  test "renders 'No Data' when there are no clicks", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/click_chart")

    view |> element("form[phx-change=\"filter\"]") |> render_change(%{"browser" => "NonExistentBrowser", "ip" => "255.255.255.255"})

    assert render(view) =~ "No Data"
  end
end
