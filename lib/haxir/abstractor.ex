defmodule Haxir.Abstractor do
  @moduledoc false

  use GenStage
  require Logger

  alias Haxir.RoomState

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state, subscribe_to: [Haxir.Producer]}
  end

  def handle_events(events, _from, state) do

    new_events = for event <- events, do: handle_event(event)

    {:noreply, new_events, state}
  end



  def handle_event({:player_joined, args}) do
    RoomState.player_joined(args["player"])
    {:player_joined, RoomState.convert_player(args["player"])}
  end

  def handle_event({:player_left, args}) do
    player = RoomState.get_player(args["player"])
    RoomState.player_left(player["id"])
    {:player_left, player}
  end

  def handle_event({:new_message, args}) do
    {:new_message, {RoomState.get_player(args["player"]), args["message"]}}
  end

  def handle_event({:room_linked, args}) do
    RoomState.set_room_link(args["link"])

    Logger.info "Room successful started. Link: #{args["link"]}"

    {:room_linked, args["link"]}
  end

  def handle_event({:admin_changed, args}) do

    RoomState.update_property(args["changedPlayer"]["id"], "admin", args["changedPlayer"]["admin"])

    {:admin_changed, {
      RoomState.get_player(args["changedPlayer"]),
      RoomState.get_player(args["byPlayer"])
    }}
  end

  def handle_event({:team_changed, args}) do

    RoomState.fix_players_order(args["changedPlayer"]["id"], args["changedPlayer"]["team"])

    {:team_changed, {
      RoomState.get_player(args["changedPlayer"]),
      RoomState.get_player(args["byPlayer"])
    }}
  end

  def handle_event({:game_ticked, args}) do
    RoomState.update_match_state(args)
    {:game_ticked, args["scores"]}
  end

  def handle_event({:game_started, args}) do
    RoomState.set_game_ocorring(true)
    {:game_started, RoomState.get_player(args["byPlayer"])}
  end
  def handle_event({:game_stopped, args}) do
    RoomState.set_game_ocorring(false)
    RoomState.set_game_paused(false)
    RoomState.update_match_state(nil)
    {:game_stopped, RoomState.get_player(args["byPlayer"])}
  end

  def handle_event({:game_paused, args}) do
    RoomState.set_game_paused(true)
    {:game_paused, RoomState.get_player(args["byPlayer"])}
  end

  def handle_event({:game_unpaused, args}) do
    RoomState.set_game_paused(false)
    {:game_unpaused, RoomState.get_player(args["byPlayer"])}
  end

  def handle_event({:team_victory, _args}) do
    scores = RoomState.get_scores()
    {:team_victory, scores}
  end

  def handle_event({:ball_kicked, args}) do
    {:ball_kicked, RoomState.get_player(args["player"])}
  end

  def handle_event({:team_scored, args}) do
    {:team_scored, args["team"]}
  end

  def handle_event({:player_kicked, args}) do
    case args["ban"] do

      true -> {:player_banned, {
        RoomState.get_player(args["kickedPlayer"]),
        args["reason"],
        RoomState.get_player(args["byPlayer"])
      }}

      _ -> {:player_kicked, {
        RoomState.get_player(args["kickedPlayer"]),
        args["reason"],
        RoomState.get_player(args["byPlayer"])
      }}

    end
  end

  def handle_event({:positions_reseted, _args}) do
    {:positions_reseted, RoomState.get_scores()}
  end

  def handle_event({:player_activity, args}) do
    {:player_activity, RoomState.get_player(args["player"])}
  end

  def handle_event({:stadium_changed, args}) do
    {:stadium_changed, {args["newStadiumName"], RoomState.get_player(args["byPlayer"])}}
  end

  def handle_event({:kick_rate_limit_set, args}) do
    {:kick_rate_limit_set, {args["min"], args["rate"], args["burst"]}}
  end

  def handle_event({:record_stopped, args}) do
    {:record_stopped, args["recording"]}
  end

  def handle_event(event) do
    event
  end

end
