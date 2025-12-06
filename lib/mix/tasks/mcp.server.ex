# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule Mix.Tasks.Mcp.Server do
  @moduledoc """
  Mix task to run the MCP AutoGluon server.

  This task starts the MCP server that provides machine learning
  capabilities via the Model Context Protocol.

  ⚠️ **DEVELOPMENT RELEASE**: This is a development release. Not for production use.

  ## Usage

      mix mcp.server

  The server will run indefinitely, communicating via stdio for MCP protocol.
  """

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    # Start the MCP application
    Application.ensure_all_started(:autogluon_mcp)

    # Keep the process running
    Process.sleep(:infinity)
  end
end
