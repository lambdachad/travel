defmodule Travel.MixProject do
  use Mix.Project

  def project do
    [
      app: :travel,
      version: "0.2.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: "Duffel API client for flights and stays",
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"},
      {:typed_struct, "~> 0.3"},
      {:bypass, "~> 2.1", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lambdachad/travel"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_url: "https://github.com/lambdachad/travel"
    ]
  end
end
