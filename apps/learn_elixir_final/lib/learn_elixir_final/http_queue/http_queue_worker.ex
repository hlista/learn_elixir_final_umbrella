defmodule LearnElixirFinal.HttpQueue.HttpQueueWorker do
  alias LearnElixirFinal.HttpQueue.BackoffLimiter

  @max_retries 5
  @jitter_range 500..2000

  def run(%{method: method, url: url, headers: headers, body: body, opts: opts, client: client, retries: retries} = req, from_pid) do
    case BackoffLimiter.allow?() do
      true ->
        case client.request(method, url, headers, body, opts) do
          {:ok, %{status: 429, headers: headers}} ->
            retry_after = get_retry_after(headers)
            BackoffLimiter.notify_429(retry_after)
            if retries < @max_retries do
              sleep_ms = retry_after + Enum.random(@jitter_range)
              Process.sleep(sleep_ms)
              run(%{req | retries: retries + 1}, from_pid)
            else
              send(from_pid, {:http_response, {:error, :max_retries_exceeded}})
            end
          {:ok, response} ->
            send(from_pid, {:http_response, {:ok, response}})
          {:error, reason} ->
            send(from_pid, {:http_response, {:error, reason}})
        end

      false ->
        # Backoff active — wait then retry
        retry_after = BackoffLimiter.backoff_ms() + Enum.random(@jitter_range)
        if retries < @max_retries do
          Process.sleep(retry_after)
          run(%{req | retries: retries + 1}, from_pid)
        else
          send(from_pid, {:http_response, {:error, :max_retries_exceeded}})
        end
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
