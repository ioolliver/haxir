defmodule Haxir.Socket do

  use GenServer
  @behaviour :cowboy_websocket

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    {:ok, %{}}
  end

  def init(req, state) do
    {:cowboy_websocket, req, state, %{idle_timeout: 24 * 60 * 60 * 1000}}
  end

  def handle_cast({:set_pid, pid}, state) do
    {:noreply, Map.put(state, :pid, pid)}
  end

  def handle_cast(data, state) when state.pid != nil do
    send(state.pid, data)
    {:noreply, state}
  end

  def handle_cast(_data, state) do
    {:noreply, state}
  end

  def websocket_init(state) do
    GenServer.cast(__MODULE__, {:set_pid, self()})
    send_to_producer(%{"message" => "ready"})
    {:ok, state}
  end

  def websocket_handle({:text, data}, state) do
    case Jason.decode(data) do
      {:ok, json} -> send_to_producer(json)
      error -> error
    end
    {:ok, state}
  end

  def websocket_handle(_, state) do
    {:ok, state}
  end

  def websocket_info({:send, data}, state) do
    {:reply, {:text, Jason.encode!(data)}, state}
  end

  def websocket_info(_message, state) do
    {:ok, state}
  end

  defp send_to_producer(data) do
    GenStage.cast(Haxir.Producer, data)
    data
  end

  # Client

  @doc """
    Sends data to the Headless Room's Browser.

    `data` must be a map.

    ## Examples
      iex> Haxir.Socket.send_data(%{action: "send_announcement", args: [content: "hi!"]})
      {:ok, %{action: "send_announcement", args: [content: "hi!"]}}

  """
  @spec send_data(%{}) :: {:ok, %{}} | {:error, :not_a_map}
  def send_data(data) when is_map(data) do
    GenServer.cast(__MODULE__, {:send, data})
    {:ok, data}
  end
  def send_data(_data) do
    {:error, :not_a_map}
  end

  @doc """
    Simulates a fake message from the Headless. It's util for tests.

    `data` must be a map.

    ## Examples
      iex> Haxir.Socket.receive_fake_data(%{"event" => "player_joined", "args" => [player: %{"name" => "john"}]})
      {:ok, %{"event" => "player_joined", "args" => [player: %{"name" => "john"}]}}

  """
  @spec receive_fake_data(%{}) :: {:ok, %{}} | {:error, :not_a_map}
  def receive_fake_data(data) when is_map(data) do
    {:ok, send_to_producer(data)}
  end
  def receive_fake_data(_data) do
    {:error, :not_a_map}
  end

end
