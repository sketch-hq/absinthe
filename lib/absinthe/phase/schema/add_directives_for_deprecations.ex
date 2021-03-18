defmodule Absinthe.Phase.Schema.AddDirectivesForDeprecations do
  @moduledoc false

  # Add "deprecated" directive for all nodes that have
  # deprecation non-empty.
  #

  use Absinthe.Phase
  alias Absinthe.Blueprint

  @spec run(Blueprint.t(), Keyword.t()) :: {:ok, Blueprint.t()}
  def run(input, _options \\ []) do
    node = Blueprint.prewalk(input, &handle_node/1)
    {:ok, node}
  end

  @spec handle_node(Blueprint.node_t()) :: Blueprint.node_t()
  defp handle_node(
         %{
           deprecation: %{reason: reason},
           directives: directives,
           source_location: source_location
         } = node
       ) do
    directive = build_deprecation_directive(reason, source_location)

    %{node | directives: [directive | directives]}
  end

  defp handle_node(node) do
    node
  end

  defp build_deprecation_directive(reason, source_location) do
    arguments =
      case reason do
        nil ->
          []

        _ when is_binary(reason) ->
          [
            %Absinthe.Blueprint.Input.Argument{
              name: "reason",
              input_value: %Absinthe.Blueprint.Input.String{
                value: reason,
                source_location: source_location
              },
              source_location: source_location
            }
          ]
      end

    %Absinthe.Blueprint.Directive{
      name: "deprecated",
      arguments: arguments
    }
  end
end
