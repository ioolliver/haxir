defmodule Haxir.Consumer do
  @moduledoc false

  defmacro __using__(_) do
    quote do

      use GenStage

      def start_link(_initial) do
        GenStage.start_link(__MODULE__, :ok)
      end

      def init(state) do
        {:consumer, state, subscribe_to: [Haxir.Abstractor]}
      end

      def handle_events(events, _from, state) do
        for event <- events, do: handle_event(event)
        {:noreply, [], state}
      end

    end
  end

end
