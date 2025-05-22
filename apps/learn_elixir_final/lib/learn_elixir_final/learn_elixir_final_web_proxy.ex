defmodule LearnElixirFinal.LearnElixirFinalWebProxy do
  @erpc_proxy %ErpcProxy{
    node_name: "learn_elixir_final_web@"
  }

  def publish(event, trigger, topic) do
    ErpcProxy.call_on_random_node(
      @erpc_proxy,
      Absinthe.Subscription,
      :publish,
      [LearnElixirFinalWeb.Endpoint, event, [{trigger, topic}]]
    )
  end
end
