defmodule LearnElixirFinal.LeagueEventWorkers.UserMatchListening do
  use Oban.Worker,
  queue: :league_listening,
  unique: [
    period: {2, :minutes},
    timestamp: :scheduled_at,
    keys: [:user_id],
    fields: [:worker, :args]
  ],
  max_attempts: 5
  alias LearnElixirFinalPg.Accounts
  alias LearnElixirFinal.LeagueEventWorkers.LeagueAccountMatchListening

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "user_id" => user_id
        }
      }) do
    case find_user_league_accounts(user_id) do
      {:ok, league_accounts} ->
        LeagueAccountMatchListening.bulk_queue_events(league_accounts)
      {:error, %ErrorMessage{code: :not_found}} ->
        {:ok, "User does not exist"}
      e -> e
    end
  end

  def queue_event(user_id) do
    %{
      user_id: user_id
    }
    |> __MODULE__.new()
    |> Oban.insert()
  end

  def find_user_league_accounts(user_id) do
    with {:ok, user} <- Accounts.find_user(%{id: user_id, preload: :league_accounts}) do
      {:ok, user.league_accounts}
    end
  end
end
