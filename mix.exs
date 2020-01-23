defmodule ExRets.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :ex_rets,
      version: @version,
      elixir: "~> 1.9",
      package: package(),
      description: "RETS client for Elixir",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "ExRets",
        source_ref: "v#{@version}",
        source_url: "https://github.com/jdavis92/ex_rets",
        groups_for_modules: [
          "Login transaction": [
            ExRets.CapabilityUris,
            ExRets.Credentials,
            ExRets.LoginResponse,
            ExRets.SessionInformation
          ],
          "Search transaction": [
            ExRets.CompactDelimiter,
            ExRets.CompactRecord,
            ExRets.SearchArguments,
            ExRets.SearchResponse
          ]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl, :xmerl]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp package do
    %{
      licenses: ["Apache-2.0"],
      maintainers: ["Josh Davis"],
      links: %{"GitHub" => "https://github.com/jdavis92/ex_rets"}
    }
  end
end
