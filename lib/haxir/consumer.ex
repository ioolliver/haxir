defmodule Haxir.Consumer do
  @moduledoc false

  defmacro plugin(module) do
    quote do
      @plugins {unquote(module)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __metadata__, do: %{plugins: @plugins}
    end
  end

  defmacro __using__(_) do
    quote do
      use GenStage
      import unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :plugins, accumulate: true)

      def start_link(_initial) do
        GenStage.start_link(__MODULE__, :ok)
      end

      def init(_) do
        {:consumer, %{}, subscribe_to: [Haxir.Abstractor]}
      end

      def handle_events(events, _from, state) do
        final_state =
          for event <- events do
            plugins =
              __metadata__().plugins |> Enum.map(fn {plugin} -> plugin end) |> Enum.reverse()

            plugins_state =
              Enum.reduce(plugins, fn x, acc ->
                {:state, plugin_state} = apply(x, :handle_event, [event, state])

                {:state, plugin_state} =
                  apply(acc, :handle_event, [event, Map.merge(state, plugin_state)])

                plugin_state
              end)

            {:state, new_state} = handle_event(event, Map.merge(state, plugins_state))

            new_state
          end
          |> Enum.reduce(fn st, acc ->
            if is_map(acc) do
              Map.merge(acc, st)
            else
              st
            end
          end)

        {:noreply, [], final_state}
      end

      @before_compile unquote(__MODULE__)
    end
  end
end
