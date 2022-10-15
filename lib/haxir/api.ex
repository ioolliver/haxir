defmodule Haxir.Api do
  @moduledoc """
    Interface for Haxball's headless API.

    All methods in this module are ran asynchronously.

    **Examples**
    ```elixir
      iex> Haxir.Api.send_message("Hello, Haxir!")
      "Hello, Haxir!"
    ```
  """

  defp get_room_state() do
    GenStage.call(Haxir.Abstractor, :get_state)
  end

  @doc """
    Sends a host announcement with message as contents.

    ## Options
    * `:targets` (list | integer) - Who will see the announcement. If not specified, then announcement will be sent to everyone.
    * `:color` (integer) - Announcement's color.
    * `:style` (string) - Announcement's style.
    * `:sound` (string) - Announcement's sound.
    * `:allow_mentions` (boolean) - If false, then message's mentioned players will not see the message bold and with notification sound. Default is true.

    None of them are required.

    ## Examples

      iex> Haxir.Api.send_message("Hello!", color: 0xFF0000, style: "bold")
      "Hello!"

      iex> Haxir.Api.send_message("Will not ping", allow_mentions: false)
      "Will not ping"

      iex> Haxir.Api.send_message("Only player with ID 2 will receive the message", targets: 2)
      "Only player with ID 2 will receive the message"

      iex> Haxir.Api.send_message("Only player with ID 1 and my_player will receive the message", targets: [1, my_player])
      "Only player with ID 1 and my_player will receive the message"
  """
  @spec send_message(String.t(), Enum.t()) :: String.t()
  def send_message(content, opts \\ []) do

    cond do

      is_number(opts[:targets]) ->
        Haxir.Socket.send_data(%{
          message: "send_announcement",
          args: %{
            content: content,
            targets: [opts[:targets]],
            color: opts[:color],
            style: opts[:style],
            sound: opts[:sound],
            allow_mentions: opts[:allow_mentions]
          }
        })

        is_map(opts[:targets]) ->
          Haxir.Socket.send_data(%{
            message: "send_announcement",
            args: %{
              content: content,
              targets: [opts[:targets]],
              color: opts[:color],
              style: opts[:style],
              sound: opts[:sound],
              allow_mentions: opts[:allow_mentions]
            }
          })

      true ->
        Haxir.Socket.send_data(%{
          message: "send_announcement",
          args: %{
            content: content,
            targets: opts[:targets],
            color: opts[:color],
            style: opts[:style],
            sound: opts[:sound],
            allow_mentions: opts[:allow_mentions]
          }
        })

    end

    content
  end


  @doc """
    Gives admin status to the specified player.

    Can be either the player's ID or the player itself.

    ## Examples

      iex> Haxir.Api.give_admin(3)
      %{id: 3, admin: true, ...}

      iex> Haxir.Api.give_admin(player)
      %{id: 5, admin: true, ...}
  """
  @spec give_admin(%{} | integer()) :: %{} | :player_not_found
  def give_admin(player) when is_map(player) do
    Haxir.Socket.send_data(%{
      message: "set_player_admin",
      args: %{
        player_id: player.id,
        admin: true
      }
    })
    Map.put(player, :admin, true)
  end
  def give_admin(id) do
    Haxir.Socket.send_data(%{
      message: "set_player_admin",
      args: %{
        player_id: id,
        admin: true
      }
    })
    case get_player(id) do
      nil -> :player_not_found
      player -> Map.put(player, :admin, true)
    end
  end


  @doc """
    Removes admin status of the specified player.

    Can be either the player's ID or the player itself.

    ## Examples

      iex> Haxir.Api.remove_admin(3)
      %{"id" => 3, "admin" => false, ...}

      iex> Haxir.Api.remove_admin(player)
      %{"id" => 5, "admin" => false, ...}
  """
  @spec remove_admin(%{} | integer()) :: %{} | :player_not_found
  def remove_admin(player) when is_map(player) do
    Haxir.Socket.send_data(%{
      message: "set_player_admin",
      args: %{
        player_id: player.id,
        admin: false
      }
    })
    Map.put(player, :admin, false)
  end
  def remove_admin(id) do
    Haxir.Socket.send_data(%{
      message: "set_player_admin",
      args: %{
        player_id: id,
        admin: false
      }
    })
    case get_player(id) do
      nil -> :player_not_found
      player -> Map.put(player, :admin, false)
    end
  end

  @doc """
    Moves the specified player to a team.

    0 - Spectators
    1 - Red
    2 - Blue

    ## Examples

      iex> Haxir.Api.set_team(4, 1)
      %{"id" => 4, "team" => 1, ...}

      iex> Haxir.Api.set_team(player, 0)
      %{"id" => 5, "team" => 0, ...}
  """
  @spec set_team(%{} | integer(), non_neg_integer()) :: %{} | :player_not_found
  def set_team(player, team) when is_map(player) do
    Haxir.Socket.send_data(%{
      message: "set_player_team",
      args: %{
        player_id: player.id,
        team: team
      }
    })
    Map.put(player, :team, team)
  end
  def set_team(id, team) do
    Haxir.Socket.send_data(%{
      message: "set_player_team",
      args: %{
        player_id: id,
        team: team
      }
    })
    case get_player(id) do
      nil -> :player_not_found
      player -> Map.put(player, :team, team)
    end
  end

  @doc """
    Returns the current list of players.

    The list follows the room's list order.

    Order ->
      `Red players`,
      `Spec players`,
      `Blue players`

    ## Examples

      iex> Haxir.Api.get_players()
      [%{"id" => 1, ...}, %{"id" => 2, ...}, %{"id" => 3, ...}]
  """
  @spec get_players() :: list(%{})
  def get_players() do
    state = get_room_state()
    for player <- state.players do
      Haxir.Helper.find_player_disc(player, state.match)
    end
  end

  @doc """
    Returns the player with the specified id.

    Returns `nil` if the player doesn't exist.

    ## Examples

      iex> Haxir.Api.get_player(3)
      %{"id" => 3, ...}

      iex> Haxir.Api.get_player(8)
      nil
  """
  @spec get_player(non_neg_integer()) :: %{} | nil
  def get_player(id) do
    state = get_room_state()
    state.players
    |> Enum.find(fn p -> p.id == id end)
  end

  @doc """
    Kicks the specified player from the room.

    Player arg can be either the player's ID or the player itself.

    Returns `:ok`

    ## Examples

      iex> Haxir.Api.kick(player, "Flood")
      :ok

      iex> Haxir.Api.kick(5, "Spam")
      :ok
  """
  @spec kick(%{} | integer(), String.t()) :: %{}
  def kick(player, reason \\ nil)
  def kick(player, reason) when is_map(player) do
    Haxir.Socket.send_data(%{
      message: "kick_player",
      args: %{
        player_id: player.id,
        reason: reason,
        ban: false
      }
    })
    :ok
  end
  def kick(id, reason) do
    Haxir.Socket.send_data(%{
      message: "kick_player",
      args: %{
        player_id: id,
        reason: reason,
        ban: false
      }
    })
    :ok
  end

  @doc """
    Bans the specified player from the room.

    Player arg can be either the player's ID or the player itself.

    Returns `:ok`

    ## Examples

      iex> Haxir.Api.ban(player, "Flood")
      :ok

      iex> Haxir.Api.ban(5, "Spam")
      :ok
  """
  @spec ban(%{} | integer(), String.t()) :: %{}
  def ban(player, reason \\ nil)
  def ban(player, reason) when is_map(player) do
    Haxir.Socket.send_data(%{
      message: "kick_player",
      args: %{
        player_id: player.id,
        reason: reason,
        ban: true
      }
    })
    :ok
  end
  def ban(id, reason) do
    Haxir.Socket.send_data(%{
      message: "kick_player",
      args: %{
        player_id: id,
        reason: reason,
        ban: true
      }
    })
    :ok
  end

  @doc """
    Clears the list of banned players.

    Returns `:ok`

    ## Examples

      iex> Haxir.Api.clear()
      :ok
  """
  @spec clear() :: :ok
  def clear() do
    Haxir.Socket.send_data(%{
      message: "clear_bans",
      args: %{}
    })
    :ok
  end
  @doc """
    Clears the ban for a player that was previously banned.

    Can be either the player's ID or the player itself.

    Returns `:ok`

    ## Examples

      iex> Haxir.Api.clear(4)
      :ok

      iex> Haxir.Api.clear(player)
      :ok
  """
  @spec clear(%{} | integer()) :: :ok
  def clear(player) when is_map(player) do
    Haxir.Socket.send_data(%{
      message: "clear_ban",
      args: %{
        player_id: player.id
      }
    })
    :ok
  end
  def clear(id) do
    Haxir.Socket.send_data(%{
      message: "clear_ban",
      args: %{
        player_id: id
      }
    })
    :ok
  end

  @doc """
    Sets room's score limit.

    Returns the score limit set

    ## Examples

      iex> Haxir.Api.set_score_limit(4)
      4
  """
  @spec set_score_limit(non_neg_integer()) :: non_neg_integer()
  def set_score_limit(score_limit) do
    Haxir.Socket.send_data(%{
      message: "set_score_limit",
      args: %{
        limit: score_limit
      }
    })
    score_limit
  end

  @doc """
    Sets room's time limit.

    Returns the time limit set

    ## Examples

      iex> Haxir.Api.set_time_limit(7)
      7
  """
  @spec set_time_limit(non_neg_integer()) :: non_neg_integer()
  def set_time_limit(time_limit) do
    Haxir.Socket.send_data(%{
      message: "set_time_limit",
      args: %{
        limit_in_minutes: time_limit
      }
    })
    time_limit
  end

  @doc """
    Sets the room current stadium.

    ## Default Stadiums
    `classic`, `easy`, `small`, `big`, `rounded`, `hockey`, `big_hockey`, `big_easy`, `big_rounded`, `huge`

    ## Custom Stadium

    You must give a path to the stadium's file. The path is relative to the root path (where your mix.exs is located).

    ## Examples

      iex> Haxir.Api.set_stadium("big_hockey")
      :ok

      iex> Haxir.Api.set_stadium("path/to/custom_stadium.hbs")
      {:ok, "path/to/custom_stadium.hbs"}

      iex> Haxir.Api.set_stadium("the/file/doesnt/exists.hbs")
      {:error, :enoent}
  """
  @spec set_stadium(String.t()) :: :ok | {:ok, String.t()} | {:error, String.t()}
  def set_stadium("classic"), do: Haxir.Socket.send_data(%{message: "set_default_stadium", args: %{stadium_name: "Classic"}})
  def set_stadium("easy"), do: Haxir.Socket.send_data(%{message: "set_default_stadium", args: %{stadium_name: "Easy"}})
  def set_stadium("small"), do: Haxir.Socket.send_data(%{message: "set_default_stadium", args: %{stadium_name: "Small"}})
  def set_stadium("big"), do: Haxir.Socket.send_data(%{message: "set_default_stadium", args: %{stadium_name: "Big"}})
  def set_stadium("rounded"), do: Haxir.Socket.send_data(%{message: "set_default_stadium", args: %{stadium_name: "Rounded"}})
  def set_stadium("hockey"), do: Haxir.Socket.send_data(%{message: "set_default_stadium", args: %{stadium_name: "Hockey"}})
  def set_stadium("big_hockey"), do: Haxir.Socket.send_data(%{message: "set_default_stadium", args: %{stadium_name: "Big Hockey"}})
  def set_stadium("big_easy"), do: Haxir.Socket.send_data(%{message: "set_default_stadium", args: %{stadium_name: "Big Easy"}})
  def set_stadium("big_rounded"), do: Haxir.Socket.send_data(%{message: "set_default_stadium", args: %{stadium_name: "Big Rounded"}})
  def set_stadium("huge"), do: Haxir.Socket.send_data(%{message: "set_default_stadium", args: %{stadium_name: "Huge"}})
  def set_stadium(path) do
    stadium_file = File.read(path)

    case stadium_file do
      {:ok, stadium} ->
        Haxir.Socket.send_data(%{
          message: "set_custom_stadium",
          args: %{
            stadium_file_contents: stadium
          }
        })
        {:ok, path}

      {:error, error} -> {:error, error}
    end
  end

  @doc """
    Locks Teams.

    Returns `:ok`

    ## Examples

      iex> Haxir.Api.lock_teams()
      :ok
  """
  @spec lock_teams() :: :ok
  def lock_teams() do
    Haxir.Socket.send_data(%{
      message: "set_teams_lock",
      args: %{
        locked: true
      }
    })
    :ok
  end

  @doc """
    Unlocks Teams.

    Returns `:ok`

    ## Examples

      iex> Haxir.Api.unlock_teams()
      :ok
  """
  @spec unlock_teams() :: :ok
  def unlock_teams() do
    Haxir.Socket.send_data(%{
      message: "set_teams_lock",
      args: %{
        locked: false
      }
    })
    :ok
  end

  @doc """
    Sets the colors of a team.

    Colors are represented as an integer, for example a pure red color is `0xFF0000`.

    Returns `:ok`

    ## Examples

      iex> Haxir.Api.set_team_colors(1, 60, 0xFF0000, [0xFFFFFF, 0xEEEEEE, 0xDDDDDD])
      :ok
  """
  @spec set_team_colors(non_neg_integer(), non_neg_integer(), non_neg_integer(), list(non_neg_integer())) :: :ok
  def set_team_colors(team, angle, text_color, colors) do
    Haxir.Socket.send_data(%{
      message: "set_team_colors",
      args: %{
        team: team,
        angle: angle,
        text_color: text_color,
        colors: colors
      }
    })
    :ok
  end

  @doc """
    Starts a match.

    Returns `:ok`

    # Examples
      iex> Haxir.Api.start_match()
      :ok
  """
  @spec start_match() :: :ok
  def start_match() do
    Haxir.Socket.send_data(%{
      message: "start_game",
      args: %{}
    })
    :ok
  end

  @doc """
    Stops a match.

    Returns `:ok`

    # Examples
      iex> Haxir.Api.stop_match()
      :ok
  """
  @spec stop_match() :: :ok
  def stop_match() do
    Haxir.Socket.send_data(%{
      message: "stop_game",
      args: %{}
    })
    :ok
  end

  @doc """
    Restarts a match.

    Returns `:ok`

    # Examples
      iex> Haxir.Api.restart_match()
      :ok
  """
  @spec restart_match() :: :ok
  def restart_match() do
    stop_match()
    start_match()
  end

  @doc """
    Pauses a match.

    Returns `:ok`

    # Examples
      iex> Haxir.Api.pause()
      :ok
  """
  @spec pause() :: :ok
  def pause() do
    Haxir.Socket.send_data(%{
      message: "pause_game",
      args: %{pause_state: true}
    })
    :ok
  end

  @doc """
    Unpauses a match.

    Returns `:ok`

    # Examples
      iex> Haxir.Api.unpause()
      :ok
  """
  @spec unpause() :: :ok
  def unpause() do
    Haxir.Socket.send_data(%{
      message: "pause_game",
      args: %{pause_state: false}
    })
    :ok
  end

  @doc """
    If a game is in progress it returns the current score information. Otherwise it returns null

    # Examples

      iex> Haxir.Api.get_scores()
      %{"time" => 14, "red" => 3, "blue" => 2, ...}
  """
  @spec get_scores() :: %{} | nil
  def get_scores() do
    state = get_room_state()
    Haxir.Helper.get_scores(state.match)
  end

  @doc """
    Gets all discs properties, including players's discs.

    # Examples

      iex> Haxir.Api.get_discs()
      [%{"x" => 72.2, "y" => 45.4, ...}, %{"x" => 13.3, "y" => 5.5, ...}]
  """
  @spec get_discs() :: %{} | nil
  def get_discs() do
    state = get_room_state()
    Haxir.Helper.get_discs(state.match)
  end

  @doc """
    Gets a disc properties by it index.

    # Examples

      iex> Haxir.Api.get_disc(3)
      %{"x" => 672.2121, "y" => 45.432, "invMass" => 1.5, ...}
  """
  @spec get_disc(non_neg_integer()) :: %{} | nil
  def get_disc(index) do
    case get_discs() do
      nil -> nil
      discs -> Enum.at(discs, index)
    end
  end

  @doc """
    Gets Ball disc properties.

    # Examples

      iex> Haxir.Api.get_ball()
      %{"x" => 372.2121, "y" => 25.432, "invMass" => 0.8, ...}
  """
  @spec get_ball() :: %{} | nil
  def get_ball() do
    get_disc(0)
  end

  @doc """
    Gets Ball disc properties from a disc list.

    # Examples

      iex> Haxir.Api.get_ball(match.discs)
      %{a: 1}
  """
  def get_ball(discs) do
    Enum.at(discs, 0)
  end

  @doc """
    Sets a disc properties by it index.

    # Examples

      iex> Haxir.Api.set_disc(3, %{"invMass" => 2})
      %{"x" => 672.2121, "y" => 45.432, "invMass" => 2, ...}
  """
  @spec set_disc(non_neg_integer(), %{}) :: %{} | :disc_not_found
  def set_disc(index, properties) do
    Haxir.Socket.send_data(%{
      message: "set_disc_properties",
      args: %{disc_index: index, properties: properties}
    })

    case get_disc(index) do

      nil -> :disc_not_found

      disc -> Map.new(disc, fn {key, value} ->

        cond do
          properties[key] -> {key, properties[key]}
          true -> {key, value}
        end

      end)

    end

  end

  @doc """
    Sets a player disc properties.

    # Examples

      iex> Haxir.Api.set_player_disc(3, %{"radius" => 20})
      %{"id" => 3, "disc" => %{"radius" => 20, ...}, ...}
  """
  @spec set_player_disc(non_neg_integer() | %{}, %{}) :: %{} | :disc_not_found
  def set_player_disc(player, properties) when is_map(player) do
    Haxir.Socket.send_data(%{
      message: "set_player_disc_properties",
      args: %{player_id: player.id, properties: properties}
    })

    new_props = case player.disc do

      nil -> nil

      disc -> Map.new(disc, fn {key, value} ->

        cond do
          properties[key] -> {key, properties[key]}
          true -> {key, value}
        end

      end)

    end

    Map.put(player, :disc, new_props)
  end
  def set_player_disc(id, properties) do
    Haxir.Socket.send_data(%{
      message: "set_player_disc_properties",
      args: %{player_id: id, properties: properties}
    })

    player = get_player(id)

    new_props = case player.disc do
      nil -> :disc_not_found
      disc -> Map.new(disc, fn {key, value} ->
        cond do
          properties[key] -> {key, properties[key]}
          true -> {key, value}
        end
      end)
    end

    case new_props do
      :disc_not_found -> :disc_not_found
      props -> Map.put(player, :disc, props)
    end
  end

  @doc """
    Clears the password of the room.

    # Examples

      iex> Haxir.Api.set_password()
      :ok
  """
  @spec set_password() :: :ok
  def set_password() do
    Haxir.Socket.send_data(%{
      message: "set_password",
      args: %{pass: nil}
    })
    :ok
  end
  @doc """
    Changes the password of the room.

    # Examples

      iex> Haxir.Api.set_password("foobar")
      "foobar"
  """
  @spec set_password(String.t()) :: String.t()
  def set_password(password) do
    Haxir.Socket.send_data(%{
      message: "set_password",
      args: %{pass: password}
    })
    password
  end

  @doc """
    Activates the recaptcha requirement to join the room.

    # Examples

      iex> Haxir.Api.require_captcha()
      :ok
  """
  @spec activate_recaptcha() :: :ok
  def activate_recaptcha() do
    Haxir.Socket.send_data(%{
      message: "set_require_captcha",
      args: %{required: true}
    })
    :ok
  end

  @doc """
    Deactivates the recaptcha requirement to join the room.

    # Examples

      iex> Haxir.Api.require_captcha()
      :ok
  """
  @spec deactivate_recaptcha() :: :ok
  def deactivate_recaptcha() do
    Haxir.Socket.send_data(%{
      message: "set_require_captcha",
      args: %{required: false}
    })
    :ok
  end

  @doc """
    First all players listed are removed, then they are reinserted in the same order they appear in the player_list

    If move_top? is true players are inserted at the top of the list, otherwise they are inserted at the bottom of the list.

    The list can be either the players IDs or the players object itself.

    # Examples

      iex> Haxir.Api.reorder_players([5, 3, 2], true)
      [5, 3, 2]

      iex> Haxir.Api.reorder_players([player1, player2, player3], false)
      [player1, player2, player3]
  """
  @spec reorder_players(list(%{} | non_neg_integer()), boolean()) :: list(%{} | non_neg_integer())
  def reorder_players(player_list, move_top? \\ false) do

    list = Enum.map(player_list, fn player ->
      cond do
        is_map(player) -> player.id
        true -> player
      end
    end)

    Haxir.Socket.send_data(%{
      message: "reorder_players",
      args: %{player_id_list: list, move_to_top: move_top?}
    })
    player_list
  end

  @doc """
    Sets the room's kick rate limits.

    `min` is the minimum number of logic-frames between two kicks. It is impossible to kick faster than this.

    `rate` works like min but lets players save up extra kicks to use them later depending on the value of burst.

    `burst` determines how many extra kicks the player is able to save up.

    # Examples

      iex> Haxir.Api.set_kick_rate_limit(5, 3, 2)
      :ok
  """
  @spec set_kick_rate_limit(integer(), integer(), integer()) :: :ok
  def set_kick_rate_limit(min, rate, burst) do
    Haxir.Socket.send_data(%{
      message: "set_kick_rate_limit",
      args: %{min: min, rate: rate, burst: burst}
    })
    :ok
  end

  @doc """
    Overrides the avatar of the target player.

    Can be either the player's ID or the player itself.

    You can clear the override by avoiding the second argument.

    # Examples

      iex> Haxir.Api.set_avatar(3, "5")
      %{"id" => 3, ...}

      iex> Haxir.Api.set_avatar(5)
      %{"id" => 5, ...}

      iex> Haxir.Api.set_avatar(player, "H")
      %{"id" => 8, ...}
  """
  @spec set_avatar(%{} | non_neg_integer()) :: %{} | nil
  @spec set_avatar(%{} | non_neg_integer(), String.t()) :: %{} | nil
  def set_avatar(player, avatar \\ nil)
  def set_avatar(player, avatar) when is_map(player) do
    Haxir.Socket.send_data(%{
      message: "set_player_avatar",
      args: %{
        player_id: player.id,
        avatar: avatar
      }
    })
    player
  end
  def set_avatar(id, avatar) do
    Haxir.Socket.send_data(%{
      message: "set_player_avatar",
      args: %{
        player_id: id,
        avatar: avatar
      }
    })
    get_player(id)
  end

  @doc """
    Updates a player's state.
  """
  def set_player_state(id, state) when is_binary(id) do
    GenStage.cast(Haxir.Abstractor, {:update_player_state, id, state})
    case get_player(id) do
      nil -> nil
      player -> Map.put(player, :state, state)
    end
  end
  def set_player_state(player, state) do
    GenStage.cast(Haxir.Abstractor, {:update_player_state, player.id, state})
    Map.put(player, :state, state)
  end

  @doc """
    Calc the distance between 2 discs.
  """
  def distance_between(d1, d2) do
    deltax = abs(d1.x - d2.x)
    deltay = abs(d1.y - d2.y)
    distance = :math.sqrt((deltax * deltax) + (deltay * deltay))
    distance - get_radius(d1[:radius]) - get_radius(d2[:radius])
  end

  defp get_radius(nil), do: 0
  defp get_radius(radius), do: radius

  @doc """
    Emits an event.
  """
  def emit_event(event) do
    GenStage.cast(Haxir.Abstractor, {:emit_event, event})
    event
  end

end
