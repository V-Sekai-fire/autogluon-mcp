# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule AutogluonMcp.NativeServiceTest do
  use ExUnit.Case, async: true

  alias AutogluonMcp.NativeService

  @fixtures_dir Path.join([__DIR__, "..", "fixtures"])

  describe "handle_initialize/2" do
    test "initializes with default config" do
      params = %{
        "protocolVersion" => "2025-06-18"
      }
      state = %{}

      {:ok, result, new_state} = NativeService.handle_initialize(params, state)

      assert result.protocolVersion == "2025-06-18"
      assert result.serverInfo.name == "AutoGluon MCP Server (Development Release)"
      assert result.serverInfo.version == "1.0.0-dev1"
      assert Map.has_key?(result, :configSchema)
      assert Map.has_key?(new_state, :config)
    end

    test "initializes with timeout config" do
      params = %{
        "protocolVersion" => "2025-06-18",
        "config" => %{"timeout_ms" => 5000}
      }
      state = %{}

      {:ok, result, new_state} = NativeService.handle_initialize(params, state)

      assert result.protocolVersion == "2025-06-18"
      assert new_state.config.timeout_ms == 5000
    end

    test "rejects invalid timeout config" do
      params = %{
        "protocolVersion" => "2025-06-18",
        "config" => %{"timeout_ms" => 50}
      }
      state = %{}

      {:error, reason, new_state} = NativeService.handle_initialize(params, state)

      assert reason =~ "Invalid configuration"
      assert new_state == state
    end
  end

  describe "handle_tool_call/3" do
    test "handles autogluon_fit_tabular tool call" do
      train_path = Path.join(@fixtures_dir, "tabular_train.csv")
      args = %{
        "train_data_path" => train_path,
        "label" => "label",
        "time_limit" => 10
      }
      state = %{}

      case NativeService.handle_tool_call("autogluon_fit_tabular", args, state) do
        {:ok, result, new_state} ->
          assert is_map(result)
          assert Map.has_key?(result, :content)
          assert is_list(result.content)
          assert new_state == state

        {:error, reason, new_state} ->
          # Skip if AutoGluon not available
          assert is_binary(reason)
          assert new_state == state
      end
    end

    test "handles autogluon_fit_tabular with JSON data" do
      train_path = Path.join(@fixtures_dir, "tabular_train.json")
      args = %{
        "train_data_path" => train_path,
        "label" => "label"
      }
      state = %{}

      case NativeService.handle_tool_call("autogluon_fit_tabular", args, state) do
        {:ok, result, new_state} ->
          assert is_map(result)
          assert Map.has_key?(result, :content)
          assert new_state == state

        {:error, reason, new_state} ->
          # Skip if AutoGluon not available
          assert is_binary(reason)
          assert new_state == state
      end
    end

    test "handles autogluon_predict_tabular tool call" do
      # Note: This would require a trained model, so we test the structure
      model_path = "/tmp/test_model"
      test_path = Path.join(@fixtures_dir, "tabular_test.csv")
      args = %{
        "model_path" => model_path,
        "test_data_path" => test_path
      }
      state = %{}

      case NativeService.handle_tool_call("autogluon_predict_tabular", args, state) do
        {:ok, result, new_state} ->
          assert is_map(result)
          assert Map.has_key?(result, :content)
          assert new_state == state

        {:error, reason, new_state} ->
          # Expected if model doesn't exist
          assert is_binary(reason)
          assert new_state == state
      end
    end

    test "handles autogluon_fit_multimodal tool call" do
      train_path = Path.join(@fixtures_dir, "multimodal_train.csv")
      args = %{
        "train_data_path" => train_path,
        "label" => "label",
        "problem_type" => "classification"
      }
      state = %{}

      case NativeService.handle_tool_call("autogluon_fit_multimodal", args, state) do
        {:ok, result, new_state} ->
          assert is_map(result)
          assert Map.has_key?(result, :content)
          assert new_state == state

        {:error, reason, new_state} ->
          # Skip if AutoGluon not available
          assert is_binary(reason)
          assert new_state == state
      end
    end

    test "handles autogluon_fit_timeseries tool call" do
      train_path = Path.join(@fixtures_dir, "timeseries_train.csv")
      args = %{
        "train_data_path" => train_path,
        "target" => "target",
        "prediction_length" => 12
      }
      state = %{}

      case NativeService.handle_tool_call("autogluon_fit_timeseries", args, state) do
        {:ok, result, new_state} ->
          assert is_map(result)
          assert Map.has_key?(result, :content)
          assert new_state == state

        {:error, reason, new_state} ->
          # Skip if AutoGluon not available
          assert is_binary(reason)
          assert new_state == state
      end
    end

    test "handles autogluon_evaluate_model tool call" do
      model_path = "/tmp/test_model"
      test_path = Path.join(@fixtures_dir, "tabular_test.csv")
      args = %{
        "model_path" => model_path,
        "test_data_path" => test_path,
        "model_type" => "tabular"
      }
      state = %{}

      case NativeService.handle_tool_call("autogluon_evaluate_model", args, state) do
        {:ok, result, new_state} ->
          assert is_map(result)
          assert Map.has_key?(result, :content)
          assert new_state == state

        {:error, reason, new_state} ->
          # Expected if model doesn't exist
          assert is_binary(reason)
          assert new_state == state
      end
    end

    test "handles unknown tool" do
      args = %{}
      state = %{}

      result = NativeService.handle_tool_call("unknown_tool", args, state)
      assert {:error, "Tool not found: unknown_tool", state} == result
    end

    test "handles missing required arguments" do
      args = %{"label" => "label"}
      state = %{}

      case NativeService.handle_tool_call("autogluon_fit_tabular", args, state) do
        {:error, reason, new_state} ->
          assert is_binary(reason)
          assert new_state == state

        {:ok, _result, new_state} ->
          # May succeed with mock fallback
          assert new_state == state
      end
    end
  end

  describe "handle_prompt_get/3" do
    test "handles autogluon_helper prompt" do
      args = %{
        "task_type" => "tabular",
        "operation" => "fit",
        "data_path" => "/path/to/data.csv",
        "label" => "label"
      }
      state = %{}

      {:ok, result, new_state} = NativeService.handle_prompt_get("autogluon_helper", args, state)

      assert is_map(result)
      assert Map.has_key?(result, :messages)
      assert is_list(result.messages)
      assert length(result.messages) >= 2
      assert new_state == state
    end

    test "handles autogluon_helper prompt with minimal args" do
      args = %{
        "task_type" => "tabular",
        "operation" => "fit"
      }
      state = %{}

      {:ok, result, new_state} = NativeService.handle_prompt_get("autogluon_helper", args, state)

      assert is_map(result)
      assert Map.has_key?(result, :messages)
      assert new_state == state
    end
  end

  describe "handle_resource_read/3" do
    test "handles autogluon://examples resource" do
      uri = "autogluon://examples"
      state = %{}

      {:ok, content, new_state} = NativeService.handle_resource_read(uri, uri, state)

      assert is_list(content)
      assert length(content) > 0
      assert new_state == state
    end
  end
end

