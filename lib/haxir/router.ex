defmodule Haxir.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  match _ do
    send_resp(conn, 200, "OK")
  end

  def dispatch() do
    [
      {:_,
       [
         {"/ws", Haxir.Socket, []}
       ]}
    ]
  end
end
