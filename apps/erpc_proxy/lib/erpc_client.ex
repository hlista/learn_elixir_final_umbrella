defmodule ErpcClient do
  @callback call_on_random_node(struct, module, function, list) ::
              any()
end
