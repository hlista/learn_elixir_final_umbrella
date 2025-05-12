defmodule RiotClient.HttpClient do
  @callback request(method :: atom(), url :: binary(), headers :: list(), body :: binary(), opts :: keyword()) ::
              {:ok, Finch.Response.t()} | {:error, any()}
end
