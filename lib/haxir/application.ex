defmodule Haxir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Haxir.Router

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Haxir.Worker.start_link(arg)
      # {Haxir.Worker, arg}

      Haxir.Producer,
      Haxir.Abstractor,

      {Plug.Cowboy, scheme: :http, plug: Router, dispatch: Router.dispatch, options: [port: 4333]},
      Haxir.Socket,
      Haxir.Browser
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Haxir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
