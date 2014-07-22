defmodule Diamorfosi.Mixfile do
  use Mix.Project

  def project do
    [ app: :diamorfosi,
      version: "0.0.1",
      elixir: "~> 0.14.0",
      deps: deps ]
  end

  def application do
    [
      mod: { Diamorfosi, [] },
      applications: [:httpoison, :jazz, :exlager],
      env: [etcd_url: "http://127.0.0.1:4001/v2/keys"],
    ]
  end

  defp deps do
    [
      {:httpoison, github: "edgurgel/httpoison"},
      {:exactor, github: "sasa1977/exactor"},
      {:exlager, github: "khia/exlager"},
      {:jazz, github: "meh/jazz"}
    ]
  end
end
