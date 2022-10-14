defmodule Mix.Tasks.Haxir.Setup do
  @moduledoc """
  Setup dependencies.

  Usage:
  mix haxir.setup (frontend path)
  """
  @shortdoc "Setup dependencies."

  use Mix.Task

  @default_frontend_path "deps/haxir/priv/frontend"

  @impl Mix.Task
  def run(args) do
    path = get_path(args)

    Mix.shell().info("Installing Frontend dependencies...")

    Mix.shell().cmd("cd #{path} && npm install", quiet: true)
    |> exit_status()
  end

  defp get_path(args) do
    path =
      if args |> Enum.any?() do
        Enum.join(args, " ")
      else
        @default_frontend_path
      end

    path
  end

  defp exit_status(0) do
    Mix.shell().info("""
    Haxir successfully configured, you can run:

      $ iex -S mix
    """)
  end

  defp exit_status(status) do
    Mix.shell().error("Something unexpected happened. Status code: #{status}")
  end
end
