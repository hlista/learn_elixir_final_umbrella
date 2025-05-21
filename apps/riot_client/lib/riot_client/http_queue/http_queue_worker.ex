defmodule RiotClient.HttpQueue.HttpQueueWorker do
  alias RiotClient.HttpQueue.BackoffLimiter

  @max_retries 5
  @jitter_range 5..20
  @region_to_backoff_limiter %{
    "americas" => :americas_backoff_limiter,
    "europe" => :europe_backoff_limiter,
    "asia" => :asia_backoff_limiter,
    "sea" => :sea_backoff_limiter
  }

  def run(%{region: region} = req, from_pid) do
    case backoff_limiter_name(region) do
      nil -> send(from_pid, {:http_response, {:error, "Invalid Region"}})
      backoff_limiter_name ->
        req
        |> Map.delete(:region)
        |> Map.put(:backoff_limiter_name, backoff_limiter_name)
        |> run(from_pid)
    end
  end

  def run(%{
    backoff_limiter_name: backoff_limiter_name
  } = req, from_pid) do
    case BackoffLimiter.allow?(backoff_limiter_name) do
      true ->
        attempt_request(req, from_pid)
      false ->
        backoff_active(req, from_pid)
    end
  end

  def attempt_request(%{
    method: method,
    url: url,
    headers: headers,
    body: body,
    opts: opts,
    client: client,
    retries: retries,
    backoff_limiter_name: backoff_limiter_name
  } = req, from_pid) do
    case client.request(method, url, headers, body, opts) do
      {:ok, %{status: 429, headers: headers}} ->
        recieved_429(req, headers, from_pid)
      {:ok, response} ->
        send(from_pid, {:http_response, {:ok, response}})
      {:error, reason} ->
        send(from_pid, {:http_response, {:error, reason}})
    end
  end

  def backoff_active(%{
    backoff_limiter_name: backoff_limiter_name,
    retries: retries
  } = req, from_pid) do
    retry_after = BackoffLimiter.backoff_ms(backoff_limiter_name) + Enum.random(@jitter_range)
    if retries < @max_retries do
      Process.sleep(retry_after)
      run(%{req | retries: retries + 1}, from_pid)
    else
      send(from_pid, {:http_response, {:error, :max_retries_exceeded}})
    end
  end

  def recieved_429(%{
    backoff_limiter_name: backoff_limiter_name,
    retries: retries
  } = req, headers, from_pid) do
    retry_after = get_retry_after(headers)
    BackoffLimiter.notify_429(backoff_limiter_name, retry_after)
    if retries < @max_retries do
      sleep_ms = retry_after + Enum.random(@jitter_range)
      Process.sleep(sleep_ms)
      run(%{req | retries: retries + 1}, from_pid)
    else
      send(from_pid, {:http_response, {:error, :max_retries_exceeded}})
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

  def backoff_limiter_name(region) do
    @region_to_backoff_limiter[region]
  end
end
