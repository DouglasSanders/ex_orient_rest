defmodule ExOrientRest.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_orient_rest,
      version: "0.1.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
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

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.0"}
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
