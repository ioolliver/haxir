defmodule Haxir.Socket.Handler do

  use Riverside, otp_app: :haxir

  @impl Riverside
  def init(session, state) do
    {:ok, session, state}
  end

  @impl Riverside
  def handle_message(msg, session, state) do

    message = msg["message"]
    args = msg["args"]

    handle_socket({message, args, session})

    {:ok, session, state}

  end

  def handle_socket({"ready", _args, session}) do
    config = Application.get_env(:haxir, :config)

    Haxir.Socket.register_session(session)

    Haxir.Socket.send_data(%{
      message: "open_room",
      args: config
    })
  end

  def handle_socket({"invalid_token", _args, _session}) do
    Logger.warn("Expired Haxball's headless token provided. Please provide a valid token on config.exs")
  end

  def handle_socket({"event", args, _session}) do
    GenStage.cast(Haxir.Producer, {:event, args})
  end

  @impl Riverside
  def terminate(_reason, _session, _state) do
    :ok
  end

end
