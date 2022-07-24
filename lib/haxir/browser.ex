defmodule Haxir.Browser do
  @moduledoc false

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
      System.cmd("node", ["priv/frontend/dist/index.js"])
    end
  end

end
