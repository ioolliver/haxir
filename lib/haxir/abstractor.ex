defmodule Haxir.Abstractor do
  @moduledoc false

  use GenStage
  require Logger
  import Haxir.Helper

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:producer_consumer, %{players: [], match: nil}, subscribe_to: [Haxir.Producer]}
  end

  def handle_cast({:update_player_state, id, new_state}, state) do
    {:noreply, [], Map.put(state, :players, update_players(state.players, id, :state, new_state))}
  end
  def handle_cast({:emit_event, event}, state) do
    {:noreply, [event], state}
  end
  def handle_cast(_cast, state), do: {:noreply, [], state}
  def handle_call(_call, _from, state), do: {:reply, state, [], state}

  def handle_events(events, _from, state) do
    handled_events = for event <- events, do: handle_event(event, state)
    {:noreply, events_to_send(handled_events), update_state(handled_events, state)}
  end

  def handle_event({:room_linked, link}, state) do
    Logger.info("Room started. Link: #{link}")
    {{:room_linked, link}, state}
  end

  def handle_event({:player_joined, player}, state) do
    converted_player = convert_player(player)
    {{:player_joined, converted_player}, Map.put(state, :players, state.players ++ [converted_player])}
  end

  def handle_event({:player_left, player}, state) do
    players = Enum.filter(state.players, fn p -> p.id != player["id"] end)
    {{:player_left, get_player(player, state)}, Map.put(state, :players, players)}
  end

  def handle_event({:new_message, {player, message}}, state) do
    {{:new_message, {get_player(player, state), message}}, state}
  end

  def handle_event({:game_ticked, match}, state) do
    if state[:time] < trunc(match["scores"]["time"]) do
      {{:clock_changed, get_scores(state.match)}, tick_update_state(state, match)}
    else
      {{:game_ticked, {convert_match(match), convert_players(state.players, match)}}, tick_update_state(state, match)}
    end
  end

  def handle_event({:team_victory, _}, state) do
    {{:team_victory, get_scores(state.match)}, state}
  end

  def handle_event({:ball_kicked, player}, state) do
    {{:ball_kicked, get_player(player, state)}, state}
  end

  def handle_event({:team_scored, team}, state) do
    {{:team_scored, team}, state}
  end

  def handle_event({:game_started, by_player}, state) do
    {{:game_started, get_player(by_player, state)}, state}
  end

  def handle_event({:game_stopped, by_player}, state) do
    {{:game_stopped, get_player(by_player, state)}, Map.put(state, :match, nil)}
  end

  def handle_event({:admin_changed, {changed_player, by_player}}, state) do
    updated_changed_player = get_player(changed_player, state)
    |> Map.put(:admin, changed_player["admin"])

    updated_players = update_players(state.players, changed_player["id"], :admin, changed_player["admin"])

    {
      {:admin_changed, {updated_changed_player, get_player(by_player, state)}},
      Map.put(state, :players, updated_players)
    }
  end

  def handle_event({:team_changed, {changed_player, by_player}}, state) do
    updated_changed_player = get_player(changed_player, state)
    |> Map.put(:team, changed_player["team"])

    {
      {:team_changed, {updated_changed_player, get_player(by_player, state)}},
      Map.put(state, :players, team_changed(state.players, updated_changed_player))
    }
  end

  def handle_event({:player_kicked, {kicked, reason, true, by}}, state) do
    {{:player_kicked, {get_player(kicked, state), get_player(by, state), reason}}, state}
  end
  def handle_event({:player_kicked, {kicked, reason, false, by}}, state) do
    {{:player_banned, {get_player(kicked, state), get_player(by, state), reason}}, state}
  end

  def handle_event({:game_paused, by_player}, state) do
    {{:game_paused, get_player(by_player, state)}, state}
  end

  def handle_event({:game_unpaused, by_player}, state) do
    {{:game_unpaused, get_player(by_player, state)}, state}
  end

  def handle_event({:positions_reseted, _}, state) do
    {{:positions_reseted, convert_match(state.match)}, state}
  end

  def handle_event({:player_activity, player}, state) do
    {{:player_activity, get_player(player, state)}, state}
  end

  def handle_event({:stadium_changed, {stadium_name, by_player}}, state) do
    {{:stadium_changed, {stadium_name, get_player(by_player, state)}}, state}
  end

  def handle_event({:kick_rate_limit_set, {min, rate, burst}}, state) do
    {{:kick_rate_limit_set, {min, rate, burst}}, state}
  end

  def handle_event({:record_stopped, recording}, state) do
    {{:record_stopped, recording}, state}
  end

  def handle_event(event, state) do
    {event, state}
  end


  defp convert_players(players, match) do
    for player <- players do
      find_player_disc(player, match)
    end
  end

  defp tick_update_state(state, match) do
    state
    |> Map.put(:time, trunc(match["scores"]["time"]))
    |> Map.put(:match, match)
  end

  defp team_changed(players, changed_player) do
    players = update_players(players, changed_player.id, :team, changed_player.team)
    |> List.delete(changed_player)

    reorder_players(players ++ [changed_player])
  end

  defp reorder_players(players) do
    red = Enum.filter(players, fn p -> p.team == 1 end)
    spec = Enum.filter(players, fn p -> p.team == 0 end)
    blue = Enum.filter(players, fn p -> p.team == 2 end)
    red ++ spec ++ blue
  end

  defp events_to_send(handled_events) do
    Enum.map(handled_events, fn {event, _state} ->
      event
    end)
  end

  defp update_state(handled_events, state) do
    Enum.map(handled_events, fn {_event, state} ->
      state
    end)
    |> Enum.reduce(fn new_state, acc ->
        if is_map(acc) do
          Map.merge(acc, new_state)
        else
          Map.merge(state, new_state)
        end
      end)
  end

end
