defmodule ClickhouseMetrics.MetricsInserterWorkerTest do
  use ClickhouseMetrics.DataCase, async: true
  alias ClickhouseMetrics.{Repo, Click, MetricsInserterWorker}

  setup do
    clicks =
      for i <- 1..5 do
        %Click{
          ip: "192.168.1.#{i}",
          user_agent: "Mozilla/5.0",
          browser: "Chrome",
          device: "Desktop"
        }
        |> Repo.insert!()
      end

    %{clicks: clicks}
  end

  test "process_batches/0 inserts and deletes records", %{clicks: clicks} do
    assert Repo.aggregate(Click, :count, :id) == length(clicks)

    assert {:ok, :ok} == MetricsInserterWorker.perform(%Oban.Job{})

    assert Repo.aggregate(Click, :count, :id) == 0
  end


end
