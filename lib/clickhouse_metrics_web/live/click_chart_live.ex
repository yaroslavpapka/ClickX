defmodule ClickhouseMetricsWeb.ClickChartLive do
  use ClickhouseMetricsWeb, :live_view
  alias Contex.{Dataset, BarChart, Plot}

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      selected_chart: :browser,
      chart_svg: render_chart(:browser),
      browsers: ClickhouseMetrics.unique_values("browser"),
      ips: ClickhouseMetrics.unique_values("ip"),
      selected_browser: nil,
      selected_ip: nil
    )}
  end

  def handle_event("change_chart", %{"chart" => chart}, socket) do
    {:noreply, assign(socket,
      selected_chart: String.to_atom(chart),
      chart_svg: render_chart(String.to_atom(chart), socket.assigns.selected_browser, socket.assigns.selected_ip)
    )}
  end

  def handle_event("filter", %{"browser" => "", "ip" => ""}, socket) do
    handle_event("filter", %{"browser" => nil, "ip" => nil}, socket)
  end

  def handle_event("filter", %{"browser" => "", "ip" => ip}, socket) do
    handle_event("filter", %{"browser" => nil, "ip" => ip}, socket)
  end

  def handle_event("filter", %{"browser" => browser, "ip" => ""}, socket) do
    handle_event("filter", %{"browser" => browser, "ip" => nil}, socket)
  end

  def handle_event("filter", %{"browser" => browser, "ip" => ip}, socket) do
    {:noreply, assign(socket,
      selected_browser: browser,
      selected_ip: ip,
      chart_svg: render_chart(socket.assigns.selected_chart, browser, ip)
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <h1 class="text-xl font-semibold text-center mb-4">Clicks Chart</h1>

      <div class="flex flex-wrap justify-center gap-4 mb-4">
        <form phx-change="change_chart">
          <select name="chart" class="w-56 px-4 py-2 border rounded-md text-base">
            <option value="browser" selected={@selected_chart == :browser}>By Browser</option>
            <option value="ip" selected={@selected_chart == :ip}>By IP</option>
            <option value="device" selected={@selected_chart == :device}>By Device</option>
            <option value="daily" selected={@selected_chart == :daily}>By Day</option>
          </select>
        </form>

        <form phx-change="filter" class="flex gap-4">
          <select name="browser" class="w-56 px-4 py-2 border rounded-md text-base">
            <option value="">All Browsers</option>
            <%= for browser <- @browsers do %>
              <option value={browser} selected={@selected_browser == browser}><%= browser %></option>
            <% end %>
          </select>
          <select name="ip" class="w-56 px-4 py-2 border rounded-md text-base">
            <option value="">All IPs</option>
            <%= for ip <- @ips do %>
              <option value={ip} selected={@selected_ip == ip}><%= ip %></option>
            <% end %>
          </select>
        </form>
      </div>

      <div class="shadow-md rounded-md p-5 flex justify-center">
        <%= raw @chart_svg %>
      </div>
    </div>
    """
  end

  defp render_chart(type, browser_filter \\ nil, ip_filter \\ nil) do
    browser_filter
    |> fetch_clicks(ip_filter, type)
    |> build_dataset(type)
    |> Plot.new(BarChart, 600, 400)
    |> Plot.to_svg()
  end

  defp fetch_clicks(browser_filter, ip_filter, type) do
    ClickhouseMetrics.list_clicks(browser_filter, ip_filter)
    |> Enum.frequencies_by(&get_grouping_key(&1, type))
    |> ensure_non_empty()
  end

  defp ensure_non_empty(clicks) when map_size(clicks) == 0, do: [["No Data", 0]]
  defp ensure_non_empty(clicks), do: Enum.map(clicks, fn {key, count} -> [key, count] end)

  defp build_dataset(data, type), do: Dataset.new(data, [to_string(type), "Clicks"])

  defp get_grouping_key(%{date: date}, :daily), do: date
  defp get_grouping_key(click, type), do: Map.get(click, type)

end
