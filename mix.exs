defmodule ExOrientRest.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_orient_rest,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:httpoison, "~> 0.8 or ~> 0.9 or ~> 0.10"},
      {:poison, "~> 1.5 or ~> 2.0 or ~> 3.0"}
    ]
  end

  defp description do
    """
    REST interface to OrientDB.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Douglas Sanders"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/DouglasSanders/ex_orient_rest"}
    ]
  end
end
