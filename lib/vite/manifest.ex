defmodule Vite.Manifest do
  @moduledoc """
  Basic parser for Vite.js manifests
  See for more details:
  - https://vitejs.dev/guide/backend-integration.html
  - https://github.com/vitejs/vite/blob/main/packages/vite/src/node/plugins/manifest.ts

  """
  alias Vite.ManifestReader
  alias Vite.Chunk
  require Logger

  @type chunk_value :: binary() | list(binary()) | nil

  @spec read() :: map()
  def read() do
    ManifestReader.read_vite()
  end

  def chunks() do
    read()
    |> Enum.map(fn {chunk_name, chunk_data} -> from_raw(chunk_name, chunk_data) end)
  end

  def chunk(chunk_name) do
    Enum.find(chunks(), &(&1.name == chunk_name))
  end

  @spec entries() :: [Chunk.t()]
  def entries() do
    chunks()
    |> Enum.filter(& &1.isEntry)
  end

  @spec entry(binary()) :: Chunk.t()
  def entry(entry_name) do
    Enum.find(entries(), &(&1.name == entry_name))
  end

  def descendent_chunks(%Chunk{} = chunk) do
    Enum.reduce(chunk.imports, [], fn chunk_name, acc_chunks ->
      child_chunk = chunk(chunk_name)
      acc_chunks ++ [child_chunk] ++ descendent_chunks(child_chunk)
    end)
  end

  # %{
  #   "css" => ["assets/main.c14674d5.css"],
  #   "file" => "assets/main.9160cfe1.js",
  #   "imports" => ["_vendor.3b127d10.js"],
  #   "isEntry" => true,
  #   "src" => "src/main.tsx"
  # }
  defp from_raw(chunk_name, chunk_data) do
    %Chunk{
      name: chunk_name,
      file: Map.get(chunk_data, "file"),
      cssfiles: Map.get(chunk_data, "css", []),
      imports: Map.get(chunk_data, "imports", []),
      isEntry: Map.get(chunk_data, "isEntry", false)
    }
  end
end
