defmodule ClickhouseMetrics.MetricsScheduler do
  use GenServer
  alias ClickhouseMetrics.MetricsInserterWorker
  alias Oban

  @interval 10_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    job = MetricsInserterWorker.new(%{}, queue: :clicks)
    Oban.insert(job)
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @interval)
  end
end
