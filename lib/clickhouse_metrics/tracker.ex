defmodule ClickhouseMetrics.MetricsStore do
  alias ClickhouseMetrics.{Repo, Click}

  def add_click(ip, user_agent, browser, device) do
    %Click{}
    |> Click.changeset(%{ip: ip, user_agent: user_agent, browser: browser, device: device})
    |> Repo.insert()
  end
end
