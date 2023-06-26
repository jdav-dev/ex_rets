defmodule ExRets.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :ex_rets,
      version: @version,
      elixir: "~> 1.14",
      name: "ExRets",
      description: "RETS client for Elixir.",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      dialyzer: [plt_add_apps: [:ex_unit]],
      preferred_cli_env: [credo: :test, dialyzer: :test, gradient: :test]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl, :xmerl]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:gradient, github: "esl/gradient", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      main: "ExRets",
      source_ref: "v#{@version}",
      source_url: "https://github.com/jdav-dev/ex_rets",
      groups_for_modules: [
        Login: [
          ExRets.CapabilityUris,
          ExRets.Credentials,
          ExRets.LoginResponse,
          ExRets.SessionInformation
        ],
        Logout: [
          ExRets.LogoutResponse
        ],
        Search: [
          ExRets.CompactDelimiter,
          ExRets.CompactRecord,
          ExRets.SearchArguments,
          ExRets.SearchResponse
        ]
      ]
    ]
  end

  defp package do
    %{
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/jdav-dev/ex_rets"}
    }
  end
end
