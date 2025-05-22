defmodule LearnElixirFinalWeb.ErpcProxy do
  @moduledoc """
  Proxy for making rpc calls

  If in test assumes you have the module you are calling in your dependencies

  If in dev or prod makes an rpc call to a random node that houses the module
  The random node is determined by it's sname
  """
  defstruct [
    node_name: nil
  ]

  if Mix.env() === :test do
    def call_on_random_node(_, module, function, params) do
      apply(module, function, params)
    end
  else
    def call_on_random_node(%__MODULE__{} = proxy, module, function, params) do
      case get_random_node(proxy) do
        "" -> {:error, "No Nodes Available"}
        node ->
          :rpc.call(node,module, function, params)
      end
    end

    defp get_random_node(%__MODULE__{node_name: nil}) do
      ""
    end

    defp get_random_node(%__MODULE__{node_name: node_name}) do
      available_nodes = Enum.filter(Node.list(),&(to_string(&1) =~ node_name))
      case available_nodes do
        [] -> ""
        available_nodes -> Enum.random(available_nodes)
      end
    end
  end
end
