defmodule Haxir.Socket.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(args) do
    init(args)
  end

  @impl true
  def init(_args) do
    children = [
      { Riverside, handler: Haxir.Socket.Handler },
      Haxir.Socket
    ]

    opts = [strategy: :one_for_one, name: Haxir.Socket.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
