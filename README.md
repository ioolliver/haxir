
# Haxir

An [Elixir](https://elixir-lang.org/) library for creating [Haxball](https://www.haxball.com/)'s headless rooms.
## Installation

Add `haxir` to your `mix.exs` deps

```elixir
def deps do
  [{:haxir, "~> 0.1.0", git: "https://github.com/ioolliver/haxir.git"}]
end
```

Then run `mix deps.get` to fetch dependencies.

Now, install puppeteer in your project using
```shell
mix haxir.setup
```

Edit or create your config file at `/config/config.exs`. To run Haxir you need to provide a headless's token:
```elixir
config :haxir, :room, 
  %{
    room_name: "Haxir's room",
    token: "thr1.AAAAA***"
  }
```
## Example usage

```elixir
defmodule ExampleConsumer do

    use Haxir.Consumer

    def handle_event({:player_joined, player}, state) do
      Haxir.Api.send_message("Welcome, #{player.name}!", targets: player)
      {:state, state}
    end

    def handle_event(_event, state) do 
        {:state, state}
    end 

end
```

## Events

Events on Haxir follow this pattern:

``def handle_event(event, state)``

### State

You always must return the state using the pattern `{:state, state}`.

**Example:**

```elixir
def handle_event(_event, state) do
  {:state, Map.put(state, :v, 1)}
  # state will be %{v: 1} on next handle_event call
end
```

### Event

Event can be the following values:

```{:player_joined, player}```

Event called when a new player joins the room.

```{:player_left, player}```

Event called when a player leaves the room.

```{:new_message, {player, message}}```

Event called when a player sends a chat message. 

Haxir always hide default player's message, so you must implements your own chat logic. You can simply do:

```elixir
def handle_event({:new_message, {player, message}}, state) do
  Haxir.Api.send_message("#{player["name"]}: #{message}")
  {:state, state}
end
```

```{:room_linked, link}```

Event called when the room link is obtained.

```{:game_ticked, {match, players}}```

Event called once for every game tick (happens 30 times per second). This is useful if you want to monitor the player and ball positions without missing any ticks.

This event is not called if the game is paused or stopped.

```{:clock_changed, scores}```

Event called every time that the clock changes.

This event is not called if the game is paused or stopped.

```{:team_victory, scores}```

Event called when a team wins.

```{:ball_kicked, player}```

Event called when a player kicks the ball.

```{:team_scored, team}```

Event called when a player leaves the room.

```{:team_scored, team}```

Event called when a team scores.

```{:game_started, by_player}```

Event called when a game starts.

```{:game_stopped, by_player}```

Event called when a game stops.

```{:admin_changed, {changed_player, by_player}}```

Event called when a player's admin rights are changed.

```{:team_changed, {changed_player, by_player}}```

Event called when a player team is changed.

```{:player_kicked, {kicked_player, reason, by_player}}```

Event called when a player has been kicked from the room. This is always called before the onPlayerLeave event.

```{:player_banned, {banned_player, reason, by_player}}```

Event called when a player has been banned from the room. This is always called before the onPlayerLeave event.

```{:game_paused, by_player}```

Event called when the game is paused.

```{:game_unpaused, by_player}```

Event called when the game is unpaused.

```{:positions_reseted, scores}```

Event called when the players and ball positions are reset after a score happens.

```{:player_activity, player}```

Event called when a player gives signs of activity, such as pressing a key. This is useful for detecting inactive players.

```{:stadium_changed, {stadium_name, by_player}}```

Event called when the stadium is changed.

```{:kick_rate_limit_set, {min, rate, burst}}```

Event called when the kick rate is set.

```{:record_stopped, recording}```

Event called when the recording is stopped.

**Example:**

```elixir
defmodule TestConsumer do
  use Haxir.Consumer
  
  def handle_event({:player_joined, player}, state) do
    Haxir.Api.send_message("Welcome, #{player.name}!")
    {:state, state}
  end
  
  def handle_event({:player_left, player}, state) do
    Haxir.Api.send_message("#{player.name} has left! :(")
    {:state, state}
  end
  
  def handle_event({:new_message, {player, message}}, state) do
    Haxir.Api.send_message("#{player.name}: #{message}")
    {:state, state}
  end
  
  # Match others events
  def handle_event(_event, state) do
    {:state, state}
  end
end
```
