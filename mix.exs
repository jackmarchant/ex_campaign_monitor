defmodule ExCampaignMonitor.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_campaign_monitor,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      name: "ExCampaignMonitor",
      source_url: "https://github.com/jackmarchant/ex_campaign_monitor",
      docs: [
        main: "ExCampaignMonitor",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.2"},
      {:jason, "~> 1.1"},
      {:mox, "~> 0.4", only: :test},
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A wrapper for Campaign Monitor JSON API
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jack Marchant"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jackmarchant/ex_campaign_monitor"}
    ]
  end
end
