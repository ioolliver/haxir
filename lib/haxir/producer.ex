defmodule Haxir.Producer do

  use GenStage
  require Logger

  def start_link(_args) do
    GenStage.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_args), do: {:producer, %{}}

  def handle_cast(data, state) do
    handle_data(data, state)
  end

  def handle_data(%{"message" => "ready"}, state) do
    open_room()
    {:noreply, [], state}
  end

  def handle_data(%{"message" => "invalid_token"}, state) do
    Logger.error("A invalid token was provided to Haxir. Provide a valid token on config.exs")
    {:noreply, [], state}
  end

  def handle_data(%{"message" => "event", "args" => event_info}, state) do
    {:noreply, [convert_event(event_info)], state}
  end

  def handle_data(_data, state) do
    {:noreply, [], state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end


  defp open_room() do
    config = Application.get_env(:haxir, :room)
    Haxir.Socket.send_data(%{message: "open_room", args: config})
  end

  defp convert_event(%{"event" => event, "args" => args}) do
    case event do

      "onPlayerJoin" -> {:player_joined, args["player"]}
      "onPlayerLeave" -> {:player_left, args["player"]}
      "onPlayerChat" -> {:new_message, {args["player"], args["message"]}}
      "onRoomLink" -> {:room_linked, args["link"]}
      "onGameTick" -> {:game_ticked, args}
      "onTeamVictory" -> {:team_victory, nil}
      "onPlayerBallKick" -> {:ball_kicked, args["player"]}
      "onTeamGoal" -> {:team_scored, args["team"]}
      "onGameStart" -> {:game_started, args["byPlayer"]}
      "onGameStop" -> {:game_stopped, args["byPlayer"]}
      "onPlayerAdminChange" -> {:admin_changed, {args["changedPlayer"], args["byPlayer"]}}
      "onPlayerTeamChange" -> {:team_changed, {args["changedPlayer"], args["byPlayer"]}}
      "onPlayerKicked" -> {:player_kicked, {args["kickedPlayer"], args["reason"], args["ban"], args["byPlayer"]}}
      "onGamePause" -> {:game_paused, args["byPlayer"]}
      "onGameUnpause" -> {:game_unpaused, args["byPlayer"]}
      "onPositionsReset" -> {:positions_reseted, nil}
      "onPlayerActivity" -> {:player_activity, args["player"]}
      "onStadiumChange" -> {:stadium_changed, {args["newStadiumName"], args["byPlayer"]}}
      "onKickRateLimitSet" -> {:kick_rate_limit_set, {args["min"], args["rate"], args["burst"]}}

      "onStopRecording" -> {:record_stopped, args["recording"]}

      _ -> {:noop}
    end
  end
  defp convert_event(_event) do
    :noop
  end

end
