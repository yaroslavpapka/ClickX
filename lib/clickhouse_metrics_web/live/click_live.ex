defmodule ClickhouseMetricsWeb.ClickLive do
  use ClickhouseMetricsWeb, :live_view
  alias ClickhouseMetrics.{UserAgentParser, MetricsStore}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, get_client_info(socket))}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center h-screen">
      <div class="absolute top-4 right-4">
        <a href="/click_chart" class="px-4 py-2 bg-green-500 text-white rounded-lg shadow-md">
          Go to Click Chart
        </a>
      </div>

      <button phx-click="click" class="px-6 py-3 bg-blue-500 text-white rounded-lg shadow-lg">
        Click me
      </button>
    </div>
    """
  end

  def handle_event("click", _params, socket) do
    case MetricsStore.add_click(
           socket.assigns.ip,
           socket.assigns.user_agent,
           Map.get(UserAgentParser.parse(socket.assigns.user_agent), :browser, "Unknown"),
           Map.get(UserAgentParser.parse(socket.assigns.user_agent), :os, "Unknown")
         ) do
      {:ok, _} -> {:noreply, put_flash(socket, :info, "Your data will be in ClickHouse in 10 seconds.")}
      _ -> {:noreply, put_flash(socket, :info, "Error")}
    end
  end

  defp get_client_info(socket) do
    %{
      user_agent: get_connect_info(socket, :user_agent),
      ip: get_ip(socket)
    }
  end

  defp get_ip(socket) do
    socket
    |> get_connect_info(:x_headers)
    |> maybe_get_ip()
    |> case do
      nil -> get_peer_ip(socket)
      ip -> ip
    end
  end

  defp maybe_get_ip(nil), do: nil
  defp maybe_get_ip(headers) do
    headers
    |> Enum.find_value(fn {key, ip} ->
      if String.downcase(key) == "x-forwarded-for", do: ip
    end)
    |> maybe_parse_ip()
  end

  defp maybe_parse_ip(nil), do: nil
  defp maybe_parse_ip(ip) do
    ip
    |> String.split(",", trim: true)
    |> List.first()
    |> String.trim()
  end

  defp get_peer_ip(socket) do
    case get_connect_info(socket, :peer_data) do
      %{address: {a, b, c, d}} -> "#{a}.#{b}.#{c}.#{d}"
      _ -> "Unknown"
    end
  end
end
