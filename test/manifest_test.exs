defmodule Vite.ManifestTest do
  use ExUnit.Case
  alias Vite.Manifest
  alias Vite.Config
  alias Vite.Chunk

  describe "read/0" do
    test "delegatees to PhxManifestReader" do
      Config.vite_manifest("test/fixtures/basic-2.0.0-beta.58.json")
      assert is_map(Manifest.read())
    end
  end

  describe "entries/0" do
    test "will collect only entry chunks and convert to Chunk structs" do
      Config.vite_manifest("test/fixtures/basic-2.0.0-beta.58.json")

      assert Manifest.entries() == [
               %Vite.Chunk{
                 isEntry: true,
                 cssfiles: ["assets/main.c14674d5.css"],
                 file: "assets/main.9160cfe1.js",
                 imports: ["_vendor.3b127d10.js"],
                 name: "src/main.tsx"
               }
             ]
    end
  end

  describe "descendent_chunks/1" do
    test "returns all descendent chunks for chunk" do
      Config.vite_manifest("test/fixtures/nested-imports.json")

      entry_chunk = Manifest.entry("main.js")
      result_chunks = Manifest.descendent_chunks(entry_chunk)
      assert length(result_chunks) == 2

      assert Enum.member?(result_chunks, %Chunk{
               name: "_shared1.js",
               file: "assets/shared1.js",
               cssfiles: ["assets/shared1.css"],
               imports: ["_shared2.js"]
             })

      assert Enum.member?(result_chunks, %Chunk{
               name: "_shared2.js",
               file: "assets/shared2.js",
               cssfiles: ["assets/shared2.css"],
               imports: []
             })
    end
  end
end
