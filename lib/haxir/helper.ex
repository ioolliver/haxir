defmodule Haxir.Helper do
  alias Haxir.Struct.{Disc, Player, Scores}

  @doc """
    Decrypt a CONN, converting it into an IP.
  """
  @spec get_ip(String.t()) :: String.t()
  def get_ip(conn) do
    ~r/../
    |> Regex.scan(conn, global: true)
    |> Enum.map(fn [x] -> String.codepoints(x) |> tl end)
    |> Enum.map(fn [x] -> x end)
    |> Enum.join("")
    |> String.replace(~r/E/, ".")
  end

  @doc """
    Converts a player into your abstract Haxir form.
  """
  @spec convert_player(%{}) :: %{}
  def convert_player(player) do
    %Player{
      id: player["id"],
      name: player["name"],
      auth: player["auth"],
      ip: get_ip(player["conn"]),
      admin: false,
      team: 0,
      disc: nil,
      state: %{}
    }
  end

  @doc """
    Gets a player object from a list.
  """
  @spec get_player(%{} | non_neg_integer(), %{}) :: %{} | nil
  def get_player(nil, _state), do: nil
  def get_player(id, state) when is_binary(id) do
    Enum.find(state.players, fn p -> p.id == id end)
    |> find_player_disc(state.match)
  end
  def get_player(player, state) do
    Enum.find(state.players, fn p -> p.id == player["id"] end)
    |> find_player_disc(state.match)
  end

  @doc """
    Gets a score from a Match map.
  """
  @spec get_scores(%{}) :: %{} | nil
  def get_scores(%{"scores" => score}) do
    %Scores{
      red_score: score["red"],
      blue_score: score["blue"],
      time: score["time"],
      time_limit: score["timeLimit"],
      score_limit: score["scoreLimit"]
    }
  end
  def get_scores(_), do: nil

  @doc """
    Gets a disc list from a Match map.
  """
  @spec get_discs(%{}) :: %{} | nil
  def get_discs(%{"discs" => discs}) do
    Enum.map(discs, fn disc ->
      convert_disc(disc)
    end)
  end
  def get_discs(_), do: []

  @doc """
    Converts a disc to Haxir's form.
  """
  @spec convert_disc(%{}) :: %{} | nil
  def convert_disc(nil), do: nil
  def convert_disc(disc) do
    %Disc{
      x: disc["x"],
      y: disc["y"],
      x_speed: disc["xspeed"],
      y_speed: disc["yspeed"],
      x_gravity: disc["xgravity"],
      y_gravity: disc["ygravity"],
      radius: disc["radius"],
      bounce: disc["bCoeff"],
      inv_mass: disc["invMass"],
      damping: disc["damping"],
      color: disc["color"],
      c_mask: disc["cMask"],
      c_group: disc["cGroup"]
    }
  end

  @doc """
    Converts a match to Haxir's form.
  """
  @spec convert_match(%{}) :: %{} | nil
  def convert_match(nil), do: nil
  def convert_match(match) do
    %{
      scores: get_scores(match),
      discs: get_discs(match)
    }
  end

  @doc """
    Find a player disc properties. If player.team == 0, then player.disc will be nil.
  """
  @spec find_player_disc(%{}, %{}) :: %{}
  def find_player_disc(player, _match) when player.team == 0, do: player
  def find_player_disc(player, nil), do: player
  def find_player_disc(player, match) do
    player_disc = match["playersDiscs"]
    |> Enum.find(fn disc -> disc["id"] == player.id end)
    |> convert_disc()

    Map.put(player, :disc, player_disc)
  end

  @doc """
    Update a player's key in a players list.
  """
  @spec update_players([%{}], non_neg_integer(), any(), any()) :: [%{}]
  def update_players(players, id, key, value) do
    Enum.map(players, fn p ->
      if p.id == id do
        Map.put(p, key, value)
      else
        p
      end
    end)
  end

end
