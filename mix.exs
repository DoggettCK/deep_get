defmodule DeepGet.MixProject do
  use Mix.Project

  def project do
    [
      app: :deep_get,
      version: "0.1.0",
      elixir: "~> 1.0",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      name: "DeepGet",
      source_url: "https://github.com/DoggettCK/deep_get",
      package: package(),
      docs: docs(),
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
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.20", only: :dev},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    """
    `DeepGet` allows you to take an object (map/struct/list/keyword list) or
    list of them, nested to an arbitrary level, and extract the values
    corresponding to a list of keys.
    """
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Chris Doggett"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/DoggettCK/deep_get"}
    ]
  end

  defp docs() do
    [
      main: "DeepGet",
      source_url: "https://github.com/DoggettCK/deep_get"
    ]
  end
end
