defmodule Ruler.MixProject do
  use Mix.Project

  def project do
    [
      app: :ruler,
      version: "0.1.0",
      elixir: "~> 1.7-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decimal_arithmetic, "~> 0.1"},
      {:decimal, "~> 1.5"},
      {:mr_t, "~> 0.6.0", only: [:test, :dev]},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},
      {:benchee, "~> 0.11", only: :dev},
      {:ex_unit_notifier, "~> 0.1", only: :test},
      {:poison, "~> 3.1", only: :test}
    ]
  end
end
