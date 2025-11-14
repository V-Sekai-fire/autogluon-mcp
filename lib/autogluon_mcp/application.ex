# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule AutogluonMcp.Application do
  @moduledoc """
  Application module for AutoGluon MCP Server.
  
  ⚠️ **DEVELOPMENT RELEASE**: Not for production use.
  """

  use Application

  @spec start(:normal | :permanent | :transient, any()) :: {:ok, pid()}
  @impl true
  def start(_type, _args) do
    # Ensure Pythonx is started for AutoGluon support
    Application.ensure_all_started(:pythonx)

    # Determine transport based on environment
    transport = get_transport()

    children =
      [
        # Validator must start first and crash if AutoGluon is not available
        {AutogluonMcp.AutogluonValidator, []}
      ] ++
        case transport do
          :http ->
            port = get_port()
            host = get_host()

            # Start NativeService directly with HTTP transport and SSE enabled
            [
              {
                AutogluonMcp.NativeService,
                [
                  transport: :http,
                  port: port,
                  host: host,
                  use_sse: true,
                  name: AutogluonMcp.NativeService
                ]
              }
            ]

          :stdio ->
            [
              {AutogluonMcp.NativeService, [name: AutogluonMcp.NativeService]},
              {AutogluonMcp.StdioServer, []}
            ]
        end

    # Use one_for_all strategy so if validator crashes, everything stops
    opts = [strategy: :one_for_all, name: AutogluonMcp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_port do
    case System.get_env("PORT") do
      nil -> 8081
      port_str -> String.to_integer(port_str)
    end
  end

  defp get_host do
    # Use 0.0.0.0 for Docker/container deployments to accept external connections
    # Use localhost for local development
    case System.get_env("HOST") do
      nil ->
        # Default to 0.0.0.0 if PORT is set (container deployment), otherwise localhost
        if System.get_env("PORT"), do: "0.0.0.0", else: "localhost"

      host ->
        host
    end
  end

  defp get_transport do
    case System.get_env("MCP_TRANSPORT") do
      "http" ->
        :http

      "stdio" ->
        :stdio

      _ ->
        # Default to http if PORT is set (Smithery deployment), otherwise stdio
        if System.get_env("PORT"), do: :http, else: :stdio
    end
  end
end

