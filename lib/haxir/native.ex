defmodule Haxir.Native do
  use Rustler,
    otp_app: :haxir,
    crate: :haxir

  def run(_path), do: :erlang.nif_error(:nif_not_loaded)
end
