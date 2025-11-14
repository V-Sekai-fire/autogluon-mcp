# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule AutogluonMcp.MixProject do
  use Mix.Project

  def project do
    [
      app: :autogluon_mcp,
      version: "1.0.0-dev1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      deps: deps(),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs"
      ],
      test_coverage: [
        summary: [threshold: 70],
        ignore_modules: [
          AutogluonMcp.NativeService,
          Mix.Tasks.Mcp.Server,
          AutogluonMcp.HttpPlugWrapper,
          AutogluonMcp.HttpServer,
          AutogluonMcp.Router
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {AutogluonMcp.Application, []},
      applications: [:logger, :ex_mcp, :pythonx, :plug_cowboy]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_mcp, git: "https://github.com/fire/ex_mcp.git", branch: "master"},
      {:jason, "~> 1.4"},
      {:pythonx, "~> 0.4.0", runtime: false},
      {:plug_cowboy, "~> 2.6"},
      {:dialyxir, "~> 1.4.6", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  # Release configuration
  defp releases do
    [
      autogluon_mcp: [
        include_executables_for: [:unix],
        applications: [autogluon_mcp: :permanent]
      ]
    ]
  end
end

