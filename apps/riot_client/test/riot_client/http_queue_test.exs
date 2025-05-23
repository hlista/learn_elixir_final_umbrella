defmodule RiotClient.HttpQueueTest do
  use ExUnit.Case
  alias RiotClient.HttpQueue

  import Mox

  setup :set_mox_from_context

  test "enqueues and mocks a get request" do
    # Set up the mock expectation
    HttpClientMock
    |> expect(:request, fn :get, "https://api.example.com/data", _headers, _body, _opts ->
      {:ok, %Finch.Response{status: 200, body: "data"}}
    end)

    req = %{
      method: :get,
      url: "https://api.example.com/data",
      headers: [],
      body: "",
      opts: [],
      region: "sea"
    }

    result = HttpQueue.enqueue_request(req)
    assert {:ok, %{status: 200, body: "data"}} = result
  end

  test "enqueues and mocks a get request with retry-after" do
    # Set up the mock expectation
    HttpClientMock
    |> expect(:request, fn :get, "https://api.example.com/data", _headers, _body, _opts ->
      {:ok, %Finch.Response{status: 429, headers: %{"retry-after" => "1"}}}
    end)
    |> expect(:request, fn :get, "https://api.example.com/data", _headers, _body, _opts ->
      {:ok, %Finch.Response{status: 200, body: "data"}}
    end)

    req = %{
      method: :get,
      url: "https://api.example.com/data",
      headers: [],
      body: "",
      opts: [],
      region: "europe"
    }

    result = HttpQueue.enqueue_request(req)
    assert {:ok, %{status: 200, body: "data"}} = result
  end

  test "enqueues and mocks a get request with retry-after, resulting in max_retries_exceeded" do
    # Set up the mock expectation
    HttpClientMock
    |> expect(:request, fn :get, "https://api.example.com/data", _headers, _body, _opts ->
      {:ok, %Finch.Response{status: 429, headers: %{"retry-after" => "1"}}}
    end)
    |> expect(:request, fn :get, "https://api.example.com/data", _headers, _body, _opts ->
      {:ok, %Finch.Response{status: 429, headers: %{"retry-after" => "1"}}}
    end)
    |> expect(:request, fn :get, "https://api.example.com/data", _headers, _body, _opts ->
      {:ok, %Finch.Response{status: 429, headers: %{"retry-after" => "1"}}}
    end)
    |> expect(:request, fn :get, "https://api.example.com/data", _headers, _body, _opts ->
      {:ok, %Finch.Response{status: 429, headers: %{"retry-after" => "1"}}}
    end)
    |> expect(:request, fn :get, "https://api.example.com/data", _headers, _body, _opts ->
      {:ok, %Finch.Response{status: 429, headers: %{"retry-after" => "1"}}}
    end)

    req = %{
      method: :get,
      url: "https://api.example.com/data",
      headers: [],
      body: "",
      opts: [],
      region: "americas"
    }

    result = HttpQueue.enqueue_request(req)
    assert {:error, :max_retries_exceeded} = result
  end
end
