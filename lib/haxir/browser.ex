defmodule Haxir.Browser do
  @moduledoc false

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    Haxir.Native.run(Path.expand(__ENV__.file <> "../../../../priv/frontend/dist/bot.js"))
    {:ok, %{}}
  end
end
