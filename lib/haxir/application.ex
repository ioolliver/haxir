defmodule Haxir.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Haxir.Browser,
      Haxir.Socket.Supervisor,
      Haxir.Producer,
      Haxir.Abstractor,
      Haxir.RoomState,

      Haxir.TestConsumer
    ]

    opts = [strategy: :one_for_one, name: Haxir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
