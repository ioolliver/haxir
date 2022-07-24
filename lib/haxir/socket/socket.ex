defmodule Haxir.Socket do
  @moduledoc false

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    {:ok, %{}}
  end

  def send_data(data) do
    GenServer.cast(__MODULE__, {:send, data})
  end

  def register_session(session) do
    GenServer.cast(__MODULE__, {:register_session, session})
  end

  @impl true
  def handle_cast({:send, data}, state) do
    Riverside.LocalDelivery.deliver({:user, state.user_id}, {:text, Poison.encode!(data)})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:register_session, session}, _state) do
    {:noreply, session}
  end

  def handle_call(:get_session, state) do
    {:reply, state, state}
  end

end
