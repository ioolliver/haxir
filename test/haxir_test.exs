defmodule HaxirTest do
  use ExUnit.Case
  doctest Haxir

  test "greets the world" do
    assert Haxir.hello() == :world
  end
end
