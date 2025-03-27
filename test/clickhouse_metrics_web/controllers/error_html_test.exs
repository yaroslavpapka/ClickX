defmodule ClickhouseMetricsWeb.ErrorHTMLTest do
  use ClickhouseMetricsWeb.ConnCase, async: true

  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(ClickhouseMetricsWeb.ErrorHTML, "404", "html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(ClickhouseMetricsWeb.ErrorHTML, "500", "html", []) == "Internal Server Error"
  end
end
