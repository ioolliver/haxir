defmodule Haxir.Struct.Scores do
  @moduledoc false

  defstruct [
    :red_score,
    :blue_score,
    :time,
    :score_limit,
    :time_limit
  ]

  defimpl Jason.Encoder do
    def encode(value, opts) do
      Jason.Encode.map(Map.from_struct(value), opts)
    end
  end

  @typedoc "The number of goals scored by the red team."
  @type red_score :: integer()

  @typedoc "The number of goals scored by the blue team."
  @type blue_score :: integer()

  @typedoc "The number of seconds elapsed (seconds don't advance while the game is paused)."
  @type time :: float()

  @typedoc "The score limit for the game."
  @type score_limit :: integer()

  @typedoc "The time limit for the game."
  @type time_limit :: float()

  @type t :: %__MODULE__{
          red_score: red_score,
          blue_score: blue_score,
          time: time,
          score_limit: score_limit,
          time_limit: time_limit
        }

  @spec to_struct(any) :: struct
  def to_struct(map) do
    struct(__MODULE__, map)
  end
end
