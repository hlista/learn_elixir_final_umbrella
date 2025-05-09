defmodule LearnElixirFinal.RealHttpClient do
  @behaviour LearnElixirFinal.HttpClient

  def request(method, url, headers, body, opts) do
    Finch.build(method, url, headers, body)
    |> Finch.request(LearnElixirFinal.Finch, opts)
  end
end
