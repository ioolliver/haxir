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
        new_state = for event <- events do
          case handle_event(event, state) do
            {:update_state, new_state} -> new_state
            _ -> :noop
          end
        end
        |> Enum.at(0)

        {:noreply, [], if is_map(new_state) do new_state else state end}
      end

    end
  end

end
