defmodule Haxir.RoomState do

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok,
      name: __MODULE__)
  end

  def init(_args) do
    {:ok, %{
      "room_link" => "",
      "players" => [],
      "match" => %{},
      "game_ocorring" => false,
      "game_paused" => false
    }}
  end

  # Client

  def set_room_link(link) do
    GenServer.cast(__MODULE__, {:room_link, link})
  end

  def get_room_link() do
    GenServer.call(__MODULE__, {:room_link})
  end

  def set_game_ocorring(state) do
    GenServer.cast(__MODULE__, {:game_ocorring, state})
  end

  def get_game_ocorring() do
    GenServer.call(__MODULE__, {:game_ocorring})
  end

  def set_game_paused(state) do
    GenServer.cast(__MODULE__, {:game_paused, state})
  end

  def get_game_paused() do
    GenServer.call(__MODULE__, {:game_paused})
  end

  def get_scores() do
    GenServer.call(__MODULE__, {:scores})
  end

  def player_joined(player) do
    GenServer.cast(__MODULE__, {:add_player, player})
  end

  def player_left(id) do
    GenServer.cast(__MODULE__, {:remove_player, id})
  end

  def get_player(id) when is_number(id) do
    GenServer.call(__MODULE__, {:get_player, id})
  end
  def get_player(player) when is_map(player) do
    GenServer.call(__MODULE__, {:get_player, player["id"]})
  end
  def get_player(_player) do
    nil
  end

  def get_players() do
    GenServer.call(__MODULE__, {:get_players})
  end

  def get_discs() do
    GenServer.call(__MODULE__, {:get_discs})
  end

  def update_property(id, key, value) do
    GenServer.cast(__MODULE__, {:update_prop, id, key, value})
  end

  def fix_players_order(id, team) do
    GenServer.cast(__MODULE__, {:fix_order, id, team})
  end

  def update_match_state(new_state) do
    GenServer.cast(__MODULE__, {:update_match, new_state})
  end

  # Server

  def handle_call({:room_link}, _from, state) do
    {:reply, state["room_link"], state}
  end

  def handle_call({:game_paused}, _from, state) do
    {:reply, state["game_paused"], state}
  end

  def handle_call({:game_ocorring}, _from, state) do
    {:reply, state["game_ocorring"], state}
  end

  def handle_call({:scores}, _from, state) do
    {:reply, state["match"]["scores"], state}
  end

  def handle_call({:get_player, id}, _from, state) do
    players = state["players"]
    player = Enum.find(players, fn p -> p["id"] == id end)

    case player do

      nil -> {:reply, nil, state}

      _ -> {:reply, player |> insert_disc_properties(state["match"]["playersDiscs"]), state}

    end

  end

  def handle_call({:get_players}, _from, state) do

    {:reply, Enum.map(state["players"], fn player ->
      player |> insert_disc_properties(state["match"]["playersDiscs"])
    end), state}
  end

  def handle_call({:get_discs}, _from, state) do
    {:reply, state["match"]["discs"], state}
  end


  def handle_cast({:room_link, link}, state) do
    {:noreply, Map.put(state, "room_link", link)}
  end

  def handle_cast({:game_ocorring, ocorring}, state) do
    {:noreply, Map.put(state, "game_ocorring", ocorring)}
  end

  def handle_cast({:game_paused, paused}, state) do
    {:noreply, Map.put(state, "game_paused", paused)}
  end

  def handle_cast({:add_player, player}, state) do
    players = state["players"]
    players = players ++ [convert_player(player)]
    {:noreply, Map.put(state, "players", players)}
  end

  def handle_cast({:remove_player, id}, state) do
    players = state["players"]
    players = Enum.filter(players, fn player -> player["id"] != id end)
    {:noreply, Map.put(state, "players", players)}
  end

  def handle_cast({:update_prop, id, key, value}, state) do
    players = state["players"]
    players = Enum.map(players, fn player ->
      if player["id"] == id do
        Map.put(player, key, value)
      else
        player
      end
    end)
    {:noreply, Map.put(state, "players", players)}
  end

  def handle_cast({:fix_order, id, team}, state) do
    players = state["players"]
    player = Enum.find(players, fn p -> p["id"] == id end)

    players = List.delete(players, player)
    players = players ++ [player |> Map.put("team", team)]

    red = Enum.filter(players, fn p -> p["team"] == 1 end)
    blue = Enum.filter(players, fn p -> p["team"] == 2 end)
    spec = Enum.filter(players, fn p -> p["team"] == 0 end)

    players = red ++ spec ++ blue

    {:noreply, Map.put(state, "players", players)}
  end

  def handle_cast({:update_match, new_state}, state) do
    {:noreply, Map.put(state, "match", new_state)}
  end

  # Utils

  defp get_ip(conn) do
    ~r/../
    |> Regex.scan(conn, global: true)
    |> Enum.map(fn [x] -> String.codepoints(x) |> tl end)
    |> Enum.map(fn [x] -> x end)
    |> Enum.join("")
    |> String.replace(~r/E/, ".")
  end

  def convert_player(player) do
    player |>
    Map.put("ip", get_ip(player["conn"])) |>
    Map.put("disc", nil) |>
    Map.delete("position") |>
    Map.delete("conn")
  end

  def insert_disc_properties(player, players_discs) do

    case player["team"] do

      0 -> player

      _ ->
        cond do

          is_list(players_discs) ->
            player_disc = Enum.find(players_discs, fn disc -> disc["id"] == player["id"] end)

            player_disc = case player_disc do
              nil -> nil
              disc -> Map.delete(disc, "id")
            end
            Map.put(player, "disc", player_disc)

          true -> player
        end

    end

  end

end
