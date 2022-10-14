defmodule Haxir.Consumer do
  @moduledoc false

  defmacro __using__(_) do
    quote do

      use GenStage

      def start_link(_initial) do
        GenStage.start_link(__MODULE__, :ok)
      end

      def init(_) do
        {:consumer, %{}, subscribe_to: [Haxir.Abstractor]}
      end

      def handle_events(events, _from, state) do
        final_state = for event <- events do
          {:state, new_state} = handle_event(event, state)
          new_state
        end
        |> Enum.reduce(fn st, acc ->
          if is_map(acc) do Map.merge(acc, st) else st end
        end)

        {:noreply, [], final_state}
      end

    end
  end

end
