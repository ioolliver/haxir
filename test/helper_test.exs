defmodule HaxirTest do
  use ExUnit.Case
  doctest Haxir.Helper
  alias Haxir.Helper
  alias Haxir.Api

  test "converts conn to IP" do
    assert Helper.get_ip("3139322E3233312E32352E3133") == "192.231.25.13"
    assert Helper.get_ip("3138362E3230342E332E3533") == "186.204.3.53"
    assert Helper.get_ip("3138362E3234392E32322E323039") == "186.249.22.209"
    assert Helper.get_ip("3137392E36362E35362E313236") == "179.66.56.126"
  end

  test "converts to abstract player" do
    player = %{"name" => "john", "conn" => "312E32", "auth" => "abc", "id" => 1, "position" => %{}}

    assert Helper.convert_player(player) ==
      %{name: "john", ip: "1.2", auth: "abc", id: 1, disc: nil, state: %{}, admin: false, team: 0}
  end

  test "gets a player from players list" do
    player = %{"name" => "john", "conn" => "312E32", "auth" => "abc", "id" => 1, "position" => %{}}

    abstract_player = Helper.convert_player(player)
    players = [abstract_player]

    assert Helper.get_player(player, %{players: players, match: nil}) == abstract_player
  end

  test "gets a player from empty list" do
    player = %{"name" => "john", "conn" => "312E32", "auth" => "abc", "id" => 1, "position" => %{}}

    assert Helper.get_player(player, %{players: [], match: nil}) == nil
  end

  test "updates a player in a list" do

    players = [
      %{id: 1, admin: false},
      %{id: 2, admin: false}
    ]

    correct_players = [
      %{id: 1, admin: true},
      %{id: 2, admin: false}
    ]

    assert Helper.update_players(players, 1, :admin, true) == correct_players
  end

  test "calc the distance between 2 discs" do

    disc1 = %{x: 0, y: 2}
    disc2 = %{x: 0, y: 0}

    assert Api.distance_between(disc1, disc2) == 2

    disc1 = %{x: 0, y: 10, radius: 1}
    disc2 = %{x: 0, y: 0, radius: 2}

    assert Api.distance_between(disc1, disc2) == 7

  end

end
