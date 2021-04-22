defmodule ViteTest do
  use ExUnit.Case
  doctest Vite

  alias Vite.Config

  def no_lf(s), do: String.replace(s, "\n", "")
  def no_indent(s), do: Regex.replace(~r/^\s+/m, s, "")
  def strip(s), do: s |> no_indent() |> no_lf()

  describe "vite_snippet/1" do
    test "returns snippet that includes import assets" do
      Config.vite_manifest("test/fixtures/nested-imports.json")

      assert {:safe, html} = Vite.vite_snippet("main.js", current_env: :prod)
      assert strip(html) == ~S{
        <link phx-track-static rel="stylesheet" href="/assets/main.css"/>
        <link phx-track-static rel="stylesheet" href="/assets/shared1.css"/>
        <link phx-track-static rel="stylesheet" href="/assets/shared2.css"/>
        <script type="module" crossorigin defer phx-track-static src="/assets/main.js"></script>
        <link rel="modulepreload" href="/assets/shared1.js">
        <link rel="modulepreload" href="/assets/shared2.js">
      } |> strip()
    end

    test "returns snippet that includes import assets with prefix" do
      Config.vite_manifest("test/fixtures/nested-imports.json")

      assert {:safe, html} = Vite.vite_snippet("main.js", current_env: :prod, prefix: "/static/")
      assert strip(html) == ~S{
        <link phx-track-static rel="stylesheet" href="/static/assets/main.css"/>
        <link phx-track-static rel="stylesheet" href="/static/assets/shared1.css"/>
        <link phx-track-static rel="stylesheet" href="/static/assets/shared2.css"/>
        <script type="module" crossorigin defer phx-track-static src="/static/assets/main.js"></script>
        <link rel="modulepreload" href="/static/assets/shared1.js">
        <link rel="modulepreload" href="/static/assets/shared2.js">
      } |> strip()
    end
  end
end
