defmodule Haxir.Struct.Player do
  @moduledoc ~S"""
  This is a struct player.

  ### Mentions through String.Chars protocol.

  You can use for mentions like:

  ```elixir
  iex> player = %Haxir.Struct.Player{name: "player", id: 1}
  ...> Api.send_message("Hello, #{player}!")

  "Hello, @player!"
  ```
  """

  alias Haxir.Struct.Disc

  defstruct [
    :id,
    :name,
    :auth,
    :ip,
    :admin,
    :team,
    :disc,
    :state
  ]

  defimpl String.Chars do
    def to_string(player), do: "@#{player.name}"
  end

  defimpl Jason.Encoder do
    def encode(value, opts) do
      Jason.Encode.map(Map.from_struct(value), opts)
    end
  end

  @typedoc "The id of the player, each player that joins the room gets a unique id that will never change."
  @type id :: integer()

  @typedoc "The player's public ID. Players can view their own ID's here: https://www.haxball.com/playerauth"
  @type name :: String.t()

  @typedoc """
  The public ID is useful to validate that a player is who he claims to be,but can't be used to verify
  that a player isn't someone else. Which means it's useful for implementing user accounts, but not
  useful for implementing a banning system.

  Can be null if the ID validation fails.
  """
  @type auth :: String.t()

  @typedoc "A string that uniquely identifies the player's connection, if two players join using the same network this string will be equal."
  @type ip :: String.t()

  @typedoc "Whether the player has admin rights."
  @type admin :: boolean()

  @typedoc "The team of the player."
  @type team :: integer()

  @typedoc "The disc of the player."
  @type disc :: Disc.t() | nil

  @typedoc "The state of the player."
  @type state :: map()

  @type t :: %__MODULE__{
          id: id,
          name: name,
          auth: auth,
          ip: ip,
          admin: admin,
          team: team,
          disc: disc,
          state: state
        }

  @spec to_struct(any) :: struct
  def to_struct(map) do
    struct(__MODULE__, map)
  end
end
