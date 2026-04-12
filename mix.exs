defmodule Boldsign.MixProject do
  @moduledoc false
  use Mix.Project

  @version "0.5.1"
  @url "https://github.com/neilberkman/boldsign"
  @maintainers [
    "Neil Berkman"
  ]

  def project do
    [
      name: "Boldsign",
      app: :boldsign,
      version: @version,
      elixir: "~> 1.17 or ~> 1.18 or ~> 1.19",
      package: package(),
      source_url: @url,
      maintainers: @maintainers,
      description: "Unofficial BoldSign Elixir Library used to interact with the e-signature REST API.",
      homepage_url: @url,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: docs(),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_add_apps: [:mix]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.16"},
      {:plug_crypto, "~> 2.0"},

      # test
      {:bypass, "~> 2.1", only: :test},
      {:mox, "~> 1.0", only: :test},

      # dev
      {:ex_doc, "~> 0.37", only: :dev},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 1.4", only: :dev, runtime: false},
      {:quokka, "~> 2.12", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "README.md",
        "CHANGELOG.md"
      ],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @url
    ]
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{
        "GitHub" => @url
      },
      files:
        ~w(lib) ++
          ~w(LICENSE mix.exs README.md CHANGELOG.md)
    ]
  end
end
