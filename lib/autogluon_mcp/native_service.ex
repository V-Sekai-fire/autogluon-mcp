# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule AutogluonMcp.NativeService do
  @moduledoc """
  Native BEAM service for AutoGluon MCP using ex_mcp library.
  Provides machine learning tools via MCP protocol.
  
  ⚠️ **DEVELOPMENT RELEASE**: Not for production use.
  """

  # Suppress warnings from ex_mcp DSL generated code
  @compile {:no_warn_undefined, :no_warn_pattern}

  use ExMCP.Server,
    name: "AutoGluon MCP Server (Development Release)",
    version: "1.0.0-dev1"

  # Define AutoGluon tools using ex_mcp DSL
  deftool "autogluon_fit_tabular" do
    meta do
      name("Fit Tabular Predictor")
      description("Trains an AutoGluon tabular predictor on training data")
    end

    input_schema(%{
      type: "object",
      properties: %{
        train_data_path: %{
          type: "string",
          description: "Path to training CSV file or JSON string of training data"
        },
        label: %{
          type: "string",
          description: "Name of the label column to predict"
        },
        time_limit: %{
          type: "integer",
          description: "Optional time limit in seconds for training (default: no limit)"
        }
      },
      required: ["train_data_path", "label"]
    })

    tool_annotations(%{
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false
    })
  end

  deftool "autogluon_predict_tabular" do
    meta do
      name("Predict with Tabular Model")
      description("Makes predictions using a trained tabular predictor")
    end

    input_schema(%{
      type: "object",
      properties: %{
        model_path: %{
          type: "string",
          description: "Path to saved model directory"
        },
        test_data_path: %{
          type: "string",
          description: "Path to test CSV file or JSON string of test data"
        }
      },
      required: ["model_path", "test_data_path"]
    })

    tool_annotations(%{
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true
    })
  end

  deftool "autogluon_fit_multimodal" do
    meta do
      name("Fit Multimodal Predictor")
      description("Trains an AutoGluon multimodal predictor for text/image/tabular data")
    end

    input_schema(%{
      type: "object",
      properties: %{
        train_data_path: %{
          type: "string",
          description: "Path to training data (CSV/Parquet) or JSON string"
        },
        label: %{
          type: "string",
          description: "Name of the label column"
        },
        problem_type: %{
          type: "string",
          description: "Problem type: 'classification', 'regression', 'ner', etc. (default: 'classification')",
          default: "classification"
        }
      },
      required: ["train_data_path", "label"]
    })

    tool_annotations(%{
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false
    })
  end

  deftool "autogluon_fit_timeseries" do
    meta do
      name("Fit Time Series Predictor")
      description("Trains an AutoGluon time series predictor for forecasting")
    end

    input_schema(%{
      type: "object",
      properties: %{
        train_data_path: %{
          type: "string",
          description: "Path to training CSV file or JSON string"
        },
        target: %{
          type: "string",
          description: "Name of the target column to forecast"
        },
        prediction_length: %{
          type: "integer",
          description: "Number of time steps to predict into the future"
        }
      },
      required: ["train_data_path", "target", "prediction_length"]
    })

    tool_annotations(%{
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false
    })
  end

  deftool "autogluon_evaluate_model" do
    meta do
      name("Evaluate Model")
      description("Evaluates a trained AutoGluon model on test data")
    end

    input_schema(%{
      type: "object",
      properties: %{
        model_path: %{
          type: "string",
          description: "Path to saved model directory"
        },
        test_data_path: %{
          type: "string",
          description: "Path to test data file"
        },
        model_type: %{
          type: "string",
          description: "Type of model: 'tabular', 'multimodal', or 'timeseries'",
          enum: ["tabular", "multimodal", "timeseries"]
        }
      },
      required: ["model_path", "test_data_path", "model_type"]
    })

    tool_annotations(%{
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true
    })
  end

  # Define prompts
  defprompt "autogluon_helper" do
    meta do
      name("AutoGluon Helper")
      description("Helps users perform machine learning tasks with AutoGluon")
    end

    arguments do
      arg(:task_type,
        required: true,
        description: "The type of ML task (tabular, multimodal, timeseries)"
      )

      arg(:operation,
        required: true,
        description: "The operation to perform (fit, predict, evaluate)"
      )

      arg(:data_path, description: "Path to data file or JSON string")
      arg(:label, description: "Name of the label/target column")
      arg(:model_path, description: "Path to saved model directory (for predict/evaluate)")
    end
  end

  # Define resources
  defresource "autogluon://examples" do
    meta do
      name("AutoGluon Example Datasets")
      description("Example datasets and usage patterns for AutoGluon")
    end

    mime_type("application/json")
  end

  # Initialize handler with optional configuration schema
  @impl true
  def handle_initialize(params, state) do
    # Validate optional configuration
    config = Map.get(params, "config", %{})

    case validate_config(config) do
      {:ok, validated_config} ->
        # Store config in state for use in tool handlers
        new_state = Map.put(state, :config, validated_config)

        # Define optional configuration schema (JSON Schema format)
        config_schema = %{
          "$schema" => "http://json-schema.org/draft-07/schema#",
          "title" => "AutoGluon MCP Server Configuration",
          "type" => "object",
          "properties" => %{
            "timeout_ms" => %{
              "type" => "integer",
              "description" =>
                "Optional maximum time in milliseconds allowed for AutoGluon operations. If not provided, no timeout is enforced. Prevents resource exhaustion and DoS attacks.",
              "minimum" => 100,
              "maximum" => 300_000,
              "examples" => [5_000, 10_000, 30_000]
            }
          },
          "additionalProperties" => false
        }

        {:ok,
         %{
           protocolVersion: Map.get(params, "protocolVersion", "2025-06-18"),
           serverInfo: %{
             name: "AutoGluon MCP Server (Development Release)",
             version: "1.0.0-dev1",
             description: "⚠️ DEVELOPMENT RELEASE - Not for production use"
           },
           capabilities: %{
             tools: %{},
             resources: %{},
             prompts: %{}
           },
           configSchema: config_schema
         }, new_state}

      {:error, reason} ->
        {:error, "Invalid configuration: #{reason}", state}
    end
  end

  defp validate_config(config) do
    case Map.get(config, "timeout_ms") do
      nil ->
        # Timeout is optional, so nil is valid
        {:ok, %{}}

      timeout when is_integer(timeout) and timeout >= 100 and timeout <= 300_000 ->
        {:ok, %{timeout_ms: timeout}}

      timeout when is_integer(timeout) ->
        {:error, "timeout_ms must be between 100 and 300000 milliseconds"}

      _ ->
        {:error, "timeout_ms must be an integer"}
    end
  end

  # Tool call handlers
  @impl true
  def handle_tool_call(tool_name, args, state) do
    case tool_name do
      "autogluon_fit_tabular" ->
        time_limit = Map.get(args, "time_limit")

        handle_autogluon_operation(
          &AutogluonMcp.AutogluonTools.fit_tabular/3,
          [args["train_data_path"], args["label"], time_limit],
          "fit tabular predictor",
          state
        )

      "autogluon_predict_tabular" ->
        handle_autogluon_operation(
          &AutogluonMcp.AutogluonTools.predict_tabular/2,
          [args["model_path"], args["test_data_path"]],
          "predict with tabular model",
          state
        )

      "autogluon_fit_multimodal" ->
        problem_type = Map.get(args, "problem_type", "classification")

        handle_autogluon_operation(
          &AutogluonMcp.AutogluonTools.fit_multimodal/3,
          [args["train_data_path"], args["label"], problem_type],
          "fit multimodal predictor",
          state
        )

      "autogluon_fit_timeseries" ->
        handle_autogluon_operation(
          &AutogluonMcp.AutogluonTools.fit_timeseries/3,
          [args["train_data_path"], args["target"], args["prediction_length"]],
          "fit time series predictor",
          state
        )

      "autogluon_evaluate_model" ->
        handle_autogluon_operation(
          &AutogluonMcp.AutogluonTools.evaluate_model/3,
          [args["model_path"], args["test_data_path"], args["model_type"]],
          "evaluate model",
          state
        )

      _ ->
        {:error, "Tool not found: #{tool_name}", state}
    end
  end

  # Helper function to reduce code duplication in tool handlers
  defp handle_autogluon_operation(function, args, operation_description, state) do
    case apply(function, args) do
      {:ok, result} ->
        result_str = Jason.encode!(result)
        {:ok, %{content: [text("#{String.capitalize(operation_description)} result: #{result_str}")]}, state}

      {:error, reason} ->
        {:error, "Failed to #{operation_description}: #{reason}", state}
    end
  end

  # Prompt handler
  @impl true
  def handle_prompt_get("autogluon_helper", args, state) do
    task_type = Map.get(args, "task_type", "tabular")
    operation = Map.get(args, "operation", "fit")
    data_path = Map.get(args, "data_path")
    label = Map.get(args, "label")
    model_path = Map.get(args, "model_path")

    guidance = build_operation_guidance(task_type, operation, data_path, label, model_path)

    messages = [
      system(
        "You are a helpful assistant for machine learning using AutoGluon. Guide users on how to use the available tools."
      ),
      user(
        "I want to #{operation} a #{task_type} model#{if data_path, do: " with data at #{data_path}", else: ""}#{if label, do: " for label #{label}", else: ""}"
      ),
      assistant(
        "#{guidance}\n\nAutoGluon tools can train models, make predictions, and evaluate performance across tabular, multimodal, and time series tasks."
      )
    ]

    {:ok, %{messages: messages}, state}
  end

  # Resource handler
  @impl true
  def handle_resource_read("autogluon://examples", _uri, state) do
    examples = %{
      "tabular" => %{
        "description" => "Tabular data prediction examples",
        "quick_start" => """
        from autogluon.tabular import TabularDataset, TabularPredictor

        data_root = 'https://autogluon.s3.amazonaws.com/datasets/Inc/'
        train_data = TabularDataset(data_root + 'train.csv')
        test_data = TabularDataset(data_root + 'test.csv')

        predictor = TabularPredictor(label='class').fit(train_data=train_data)
        predictions = predictor.predict(test_data)
        """,
        "use_cases" => ["Classification", "Regression", "Feature importance", "Ensemble models"]
      },
      "multimodal" => %{
        "description" => "Multimodal prediction examples (text, image, text+image)",
        "quick_start" => """
        from autogluon.multimodal import MultiModalPredictor

        predictor = MultiModalPredictor(label='label').fit(train_data=train_data)
        predictions = predictor.predict(test_data)
        """,
        "use_cases" => ["Text classification", "Image classification", "NER", "Object detection", "Semantic matching"]
      },
      "timeseries" => %{
        "description" => "Time series forecasting examples",
        "quick_start" => """
        from autogluon.timeseries import TimeSeriesDataFrame, TimeSeriesPredictor

        data = TimeSeriesDataFrame('https://autogluon.s3.amazonaws.com/datasets/timeseries/m4_hourly/train.csv')
        predictor = TimeSeriesPredictor(target='target', prediction_length=48).fit(data)
        predictions = predictor.predict(data)
        """,
        "use_cases" => ["Forecasting", "Anomaly detection", "Demand prediction"]
      }
    }

    content = [
      text("""
      AutoGluon Example Usage Patterns

      #{Jason.encode!(examples, pretty: true)}

      Use these examples with the appropriate AutoGluon tools to perform machine learning tasks.
      """)
    ]

    {:ok, content, state}
  end

  # Prompt handler
  defp build_operation_guidance(task_type, operation, data_path, label, model_path) do
    guidance_map = %{
      {"tabular", "fit"} => fn ->
        "To fit a tabular predictor with data at #{data_path || "your data path"} for label #{label || "your label"}, use the autogluon_fit_tabular tool."
      end,
      {"tabular", "predict"} => fn ->
        "To predict with a tabular model at #{model_path || "your model path"} on test data at #{data_path || "your test data path"}, use the autogluon_predict_tabular tool."
      end,
      {"multimodal", "fit"} => fn ->
        "To fit a multimodal predictor with data at #{data_path || "your data path"} for label #{label || "your label"}, use the autogluon_fit_multimodal tool."
      end,
      {"timeseries", "fit"} => fn ->
        "To fit a time series predictor with data at #{data_path || "your data path"} for target #{label || "your target"}, use the autogluon_fit_timeseries tool."
      end,
      {_, "evaluate"} => fn ->
        "To evaluate a #{task_type} model at #{model_path || "your model path"} on test data at #{data_path || "your test data path"}, use the autogluon_evaluate_model tool with model_type='#{task_type}'."
      end
    }

    case Map.get(guidance_map, {task_type, operation}) do
      nil ->
        "Available operations for #{task_type}: fit, predict, evaluate. Use the appropriate AutoGluon tool for your task."

      guidance_fn ->
        guidance_fn.()
    end
  end
end

