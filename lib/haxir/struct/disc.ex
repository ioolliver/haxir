defmodule Haxir.Struct.Disc do
  @moduledoc false

  defstruct [
    :x,
    :y,
    :x_speed,
    :y_speed,
    :x_gravity,
    :y_gravity,
    :radius,
    :bounce,
    :inv_mass,
    :damping,
    :color,
    :c_mask,
    :c_group
  ]

  defimpl Jason.Encoder do
    def encode(value, opts) do
      Jason.Encode.map(Map.from_struct(value), opts)
    end
  end

  @typedoc "The x coordinate of the disc's position."
  @type x :: float()

  @typedoc "The y coordinate of the disc's position."
  @type y :: float()

  @typedoc "The x coordinate of the disc's speed vector."
  @type x_speed :: float()

  @typedoc "The y coordinate of the disc's speed vector."
  @type y_speed :: float()

  @typedoc "The x coordinate of the disc's gravity vector."
  @type x_gravity :: float()

  @typedoc "The y coordinate of the disc's gravity vector."
  @type y_gravity :: float()

  @typedoc "The disc's radius."
  @type radius :: float()

  @typedoc "The disc's bouncing coefficient."
  @type bounce :: float()

  @typedoc "The inverse of the disc's mass."
  @type inv_mass :: float()

  @typedoc "The disc's damping factor."
  @type damping :: float()

  @typedoc "The disc's color expressed as an integer (0xFF0000 is red, 0x00FF00 is green, 0x0000FF is blue, -1 is transparent)."
  @type color :: integer()

  @typedoc "The disc's collision mask (Represents what groups the disc can collide with)."
  @type c_mask :: integer()

  @typedoc "The disc's collision groups."
  @type c_group :: integer()

  @type t :: %__MODULE__{
          x: x,
          y: y,
          x_speed: x_speed,
          y_speed: y_speed,
          x_gravity: x_gravity,
          y_gravity: y_gravity,
          radius: radius,
          bounce: bounce,
          inv_mass: inv_mass,
          damping: damping,
          color: color,
          c_mask: c_mask,
          c_group: c_group
        }

  @spec to_struct(any) :: struct
  def to_struct(map) do
    struct(__MODULE__, map)
  end
end
