defmodule LearnElixirFinal.HttpQueue.HttpQueueWorker do
  alias LearnElixirFinal.HttpQueue.BackoffLimiter

  def run(url, from_pid) do
    case BackoffLimiter.allow?() do
      true ->
        case Finch.build(:get, url) |> Finch.request(LearnElixirFinal.Finch) do
          {:ok, %{status: 429, headers: headers}} ->
            retry_after = get_retry_after(headers)
            BackoffLimiter.notify_429(retry_after)
            send(from_pid, {:http_response, {:error, :rate_limited}})
          {:ok, response} ->
            send(from_pid, {:http_response, {:ok, response}})
          {:error, reason} ->
            send(from_pid, {:http_response, {:error, reason}})
        end

      false ->
        send(from_pid, {:http_response, {:error, :backoff_active}})
    end
  end

  defp get_retry_after(headers) do
    headers
    |> Enum.find(fn {k, _} -> String.downcase(k) == "retry-after" end)
    |> case do
      {_, val} -> parse_retry_after(val)
      _ -> nil
    end
  end

  defp parse_retry_after(val) do
    case Integer.parse(val) do
      {n, _} -> n
      _ -> nil
    end
  end
end
