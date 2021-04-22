defmodule Vite do
  @moduledoc """
  Documentation for `Vite`.
  """
  alias Vite.{Config, Manifest, React, View}

  defdelegate vite_client, to: View

  defdelegate inlined_phx_manifest, to: View
  defdelegate react_refresh_snippet, to: React

  def vite_snippet(entrypoint_name, opts \\ []) do
    current_env = Keyword.get(opts, :current_env, Config.current_env())
    prefix = Keyword.get(opts, :prefix, "/")

    case current_env do
      :prod ->
        case Manifest.entry(entrypoint_name) do
          nil ->
            {:safe, ""}

          entry_chunk ->
            View.entrypoint_snippet(entry_chunk, Manifest.descendent_chunks(entry_chunk),
              prefix: prefix
            )
        end

      _ ->
        View.dev_entrypoint_snippet(entrypoint_name)
    end
  end

  def is_prod() do
    Vite.Config.current_env() == :prod
  end
end
