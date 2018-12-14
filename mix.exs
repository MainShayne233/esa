defmodule ESA.MixProject do
  use Mix.Project

  def project do
    [
      app: :esa,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:typed_struct, "~> 0.1.4"},
      # dev only
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end
end
