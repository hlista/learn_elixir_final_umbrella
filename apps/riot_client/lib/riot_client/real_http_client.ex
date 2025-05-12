defmodule RiotClient.RealHttpClient do
  @behaviour RiotClient.HttpClient

  def request(method, url, headers, body, opts) do
    method
    |> Finch.build(url, headers, body)
    |> Finch.request(RiotClient.Finch, opts)
  end
end
