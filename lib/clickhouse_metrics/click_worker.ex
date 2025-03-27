defmodule ClickhouseMetrics.MetricsInserterWorker do
  use Oban.Worker, queue: :clicks, max_attempts: 3
  import Ecto.Query
  require Logger
  alias ClickhouseMetrics.{Repo, Click}

  @batch_size 1000

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    process_batches()
  end

  defp process_batches do
    Repo.transaction(fn ->
      process_next_batch()
    end)
  end

  defp process_next_batch do
    Repo.all(from c in Click, limit: @batch_size, select: {c.id, c})
    |> handle_batch()
  end

  defp handle_batch([]), do: :ok

  defp handle_batch(clicks) do
    {ids, records} = Enum.unzip(clicks)

    with :ok <- try_insert(records),
         {:ok, _} <- try_delete(ids) do
      process_next_batch()
    else
      {:error, reason} ->
        Logger.error("Failed to process batch: #{inspect(reason)}")
        :error
    end
  end

  defp try_insert(records) do
    case ClickhouseMetrics.insert_metrics(records) do
      :ok -> :ok
      _ -> {:error, :insert_failed}
    end
  end

  defp try_delete(ids) do
    case Repo.delete_all(from c in Click, where: c.id in ^ids) do
      {count, _} when count > 0 -> {:ok, count}
      _ -> {:error, :delete_failed}
    end
  end
end
