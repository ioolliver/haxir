defmodule Haxir.TestConsumer do
  use Haxir.Consumer

  def handle_event({:admin_changed, {changed_player, _byplayer}}, state) do
    IO.inspect changed_player
    state
  end

  def handle_event({:new_message, {player, _message}}, state) do
    IO.inspect player
    state
  end

  def handle_event(_event, state) do
    state
  end
end
