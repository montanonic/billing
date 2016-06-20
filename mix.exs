defmodule Billing.Mixfile do
  use Mix.Project

  def project do
    [app: :billing,
     version: "0.0.1",
     elixir: "~> 1.2",
     dialyzer: [
       plt_add_apps: ~w|phoenix phoenix_pubsub phoenix_ecto phoenix_html
        phoenix_live_reload cowboy httpoison absinthe absinthe_plug joken
        plug ecto|,
       flags: ["-Wunmatched_returns",
               "-Werror_handling",
               "-Wrace_conditions", #can potentially not finish evaluating
               "-Wunderspecs",
               "-Wunknown",
               "-Woverspecs",
               "-Wspecdiffs"
              ]],
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Billing, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger,
                    :gettext, :phoenix_ecto, :postgrex, :httpoison, :joken, 
                    :timex,]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.0-rc"},
     {:phoenix_pubsub, "~> 1.0.0-rc"},
     {:phoenix_ecto, "~> 3.0-rc"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     # added deps
     {:httpoison, "~> 0.8.3"},
     {:absinthe, "~> 1.1"},
     {:absinthe_plug, "~> 1.1"},
     {:joken, "~> 1.2"},
     {:dialyxir, "~> 0.3.3", only: [:dev]},
     {:timex, "~> 2.1"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
