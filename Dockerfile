# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

FROM hexpm/elixir:1.18.0-erlang-27.0.0-ubuntu-jammy-20231004

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod

# Copy application code
COPY . .

# Compile application
RUN MIX_ENV=prod mix compile

# Build release
RUN MIX_ENV=prod mix release

# Expose port
EXPOSE 8081

# Set environment variables
ENV MIX_ENV=prod
ENV PORT=8081
ENV MCP_TRANSPORT=http

# Run the release
CMD ["./_build/prod/rel/autogluon_mcp/bin/autogluon_mcp", "start"]

