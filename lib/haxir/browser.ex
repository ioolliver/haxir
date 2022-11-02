defmodule Haxir.Browser do
  @moduledoc false

  @default_frontend_path "../../../../priv/frontend/dist/index.js"

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok,
      name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    run()
    {:ok, %{}}
  end

  defp run() do
    spawn fn ->
      path = Path.expand(__ENV__.file <> @default_frontend_path)
      Mix.shell().cmd("node #{path}")
    end
  end

end
