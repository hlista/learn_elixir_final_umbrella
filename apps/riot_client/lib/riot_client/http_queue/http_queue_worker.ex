defmodule RiotClient.HttpQueue.HttpQueueWorker do
  alias RiotClient.HttpQueue.BackoffLimiterTwo

  @max_retries 5
  @jitter_range 500..2000
  @base_delay 1_000
  @max_delay 60_000

  def run(%{method: method, url: url, headers: headers, body: body, opts: opts, client: client, retries: retries, region: region} = req, from_pid) do
    case BackoffLimiterTwo.allow?(region) do
      true ->
        case client.request(method, url, headers, body, opts) do
          # {:ok, %{status: 429, headers: headers}} ->
          #   if retries < @max_retries do
          #     sleep_ms = retry_after + Enum.random(@jitter_range)
          #     Process.sleep(sleep_ms)
          #     run(%{req | retries: retries + 1}, from_pid)
          #   else
          #     send(from_pid, {:http_response, {:error, :max_retries_exceeded}})
          #   end
          {:ok, response} ->
            send(from_pid, {:http_response, {:ok, response}})
          {:error, reason} ->
            send(from_pid, {:http_response, {:error, reason}})
        end

      false ->
        if retries < @max_retries do
          Process.sleep(exponential_backoff(retries))
          run(%{req | retries: retries + 1}, from_pid)
        else
          send(from_pid, {:http_response, {:error, :max_retries_exceeded}})
        end
    end
  end

  # defp get_retry_after(headers) do
  #   headers
  #   |> Enum.find(fn {k, _} -> String.downcase(k) == "retry-after" end)
  #   |> case do
  #     {_, val} -> parse_retry_after(val)
  #     _ -> nil
  #   end
  # end

  # defp parse_retry_after(val) do
  #   case Integer.parse(val) do
  #     {n, _} -> n
  #     _ -> nil
  #   end
  # end

  def exponential_backoff(retries) do
    exponential = min(@base_delay * :math.pow(2, retries) |> round(), @max_delay)
    exponential + Enum.random(@jitter_range)
  end
end
