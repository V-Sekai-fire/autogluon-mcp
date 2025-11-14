# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

import Config

# Configure Pythonx to install AutoGluon
config :pythonx, :uv_init,
  pyproject_toml: """
  [project]
  name = "mcp_aria_autogluon"
  version = "0.1.0"
  requires-python = ">=3.8"
  dependencies = [
    "autogluon>=1.4.0",
    "pandas>=1.5.0",
    "numpy>=1.21.0"
  ]
  """

