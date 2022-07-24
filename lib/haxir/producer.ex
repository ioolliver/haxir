defmodule Haxir.Producer do
  @moduledoc false

  use GenStage

  def start_link(initial \\ 0) do
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def init(_args), do: {:producer, %{}}

  defp convert_event(args) do
    case args["event"] do

      "onPlayerJoin" -> {:player_joined, args["args"]}
      "onPlayerLeave" -> {:player_left, args["args"]}
      "onPlayerChat" -> {:new_message, args["args"]}
      "onRoomLink" -> {:room_linked, args["args"]}
      "onGameTick" -> {:game_ticked, args["args"]}
      "onTeamVictory" -> {:team_victory, args["args"]}
      "onPlayerBallKick" -> {:ball_kicked, args["args"]}
      "onTeamGoal" -> {:team_scored, args["args"]}
      "onGameStart" -> {:game_started, args["args"]}
      "onGameStop" -> {:game_stopped, args["args"]}
      "onPlayerAdminChange" -> {:admin_changed, args["args"]}
      "onPlayerTeamChange" -> {:team_changed, args["args"]}
      "onPlayerKicked" -> {:player_kicked, args["args"]}
      "onGamePause" -> {:game_paused, args["args"]}
      "onGameUnpause" -> {:game_unpaused, args["args"]}
      "onPositionsReset" -> {:positions_reseted, args["args"]}
      "onPlayerActivity" -> {:player_activity, args["args"]}
      "onStadiumChange" -> {:stadium_changed, args["args"]}
      "onKickRateLimitSet" -> {:kick_rate_limit_set, args["args"]}
      
      "onStopRecording" -> {:record_stopped, args["args"]}

      _ -> {:noop}

    end
  end

  def handle_cast({:event, args}, state) do
    {:noreply, [convert_event(args)], state}
  end

  def handle_cast(_, state) do
    {:noreply, [], state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
