defmodule ClickhouseMetricsWeb.ClickLive do
  use ClickhouseMetricsWeb, :live_view
  alias ClickhouseMetrics.{UserAgentParser, MetricsStore}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, get_client_info(socket))}
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center h-screen">
      <button phx-click="click" class="px-6 py-3 bg-blue-500 text-white rounded-lg shadow-lg">
        Click me
      </button>
    </div>
    """
  end

  def handle_event("click", _params, socket) do
    with %{browser: browser, os: device} <- UserAgentParser.parse(socket.assigns.user_agent),
         :ok <- MetricsStore.add_click(socket.assigns.ip, socket.assigns.user_agent, browser, device) do
      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end

  defp get_client_info(socket) do
    %{
      user_agent: get_connect_info(socket, :user_agent),
      ip: get_ip(socket)
    }
  end

  defp get_ip(socket) do
    with {:ok, headers} <- get_connect_info(socket, :x_headers),
         {_, ip} <- Enum.find(headers, fn {key, _} -> String.downcase(key) == "x-forwarded-for" end),
         [first_ip | _] <- String.split(ip, ","),
         trimmed_ip <- String.trim(first_ip) do
      trimmed_ip
    else
      _ -> get_peer_ip(socket)
    end
  end

  defp get_peer_ip(socket) do
    case get_connect_info(socket, :peer_data) do
      %{address: {a, b, c, d}} -> "#{a}.#{b}.#{c}.#{d}"
      _ -> "Unknown"
    end
  end
end
