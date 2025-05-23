ExUnit.start()
Mox.defmock(HttpClientMock, for: RiotClient.HttpClient)
Application.put_env(:riot_client, :http_client, HttpClientMock)
