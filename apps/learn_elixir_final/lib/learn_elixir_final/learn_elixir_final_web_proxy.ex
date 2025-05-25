defmodule LearnElixirFinal.LearnElixirFinalWebProxy do
  @erpc_proxy %ErpcProxy{
    node_name: "learn_elixir_final_web@"
  }

  defp client, do: Application.get_env(:learn_elixir_final, :erpc_client)

  def publish(event, trigger, topic) do
    client().call_on_random_node(
      @erpc_proxy,
      Absinthe.Subscription,
      :publish,
      [LearnElixirFinalWeb.Endpoint, event, [{trigger, topic}]]
    )
  end
end
