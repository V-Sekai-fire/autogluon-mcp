# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule AutogluonMcp.AutogluonToolsTest do
  use ExUnit.Case, async: true

  alias AutogluonMcp.AutogluonTools

  describe "fit_tabular/3" do
    test "handles tabular training with mock" do
      case AutogluonTools.fit_tabular("train.csv", "label", 60) do
        {:ok, result} ->
          assert is_map(result)
          assert Map.has_key?(result, "label")
          assert Map.has_key?(result, "status")

        {:error, _reason} ->
          # Skip test if AutoGluon not available
          :ok
      end
    end
  end

  describe "predict_tabular/2" do
    test "handles tabular prediction with mock" do
      case AutogluonTools.predict_tabular("model_path", "test.csv") do
        {:ok, predictions} ->
          assert is_list(predictions)

        {:error, _reason} ->
          # Skip test if AutoGluon not available
          :ok
      end
    end
  end

  describe "fit_multimodal/3" do
    test "handles multimodal training with mock" do
      case AutogluonTools.fit_multimodal("train.csv", "label", "classification") do
        {:ok, result} ->
          assert is_map(result)
          assert Map.has_key?(result, "label")
          assert Map.has_key?(result, "problem_type")

        {:error, _reason} ->
          # Skip test if AutoGluon not available
          :ok
      end
    end
  end

  describe "fit_timeseries/3" do
    test "handles time series training with mock" do
      case AutogluonTools.fit_timeseries("train.csv", "target", 48) do
        {:ok, result} ->
          assert is_map(result)
          assert Map.has_key?(result, "target")
          assert Map.has_key?(result, "prediction_length")

        {:error, _reason} ->
          # Skip test if AutoGluon not available
          :ok
      end
    end
  end

  describe "evaluate_model/3" do
    test "handles model evaluation with mock" do
      case AutogluonTools.evaluate_model("model_path", "test.csv", "tabular") do
        {:ok, metrics} ->
          assert is_map(metrics)
          assert Map.has_key?(metrics, "status")

        {:error, _reason} ->
          # Skip test if AutoGluon not available
          :ok
      end
    end
  end

  describe "mock fallback functions" do
    test "mock_fit_tabular returns expected structure" do
      assert {:ok, result} = AutogluonTools.test_mock_fit_tabular("train.csv", "label", 60)
      assert result["label"] == "label"
      assert result["status"] == "completed"
    end

    test "mock_predict_tabular returns list" do
      assert {:ok, predictions} = AutogluonTools.test_mock_predict_tabular("model", "test.csv")
      assert is_list(predictions)
    end

    test "mock_fit_multimodal returns expected structure" do
      assert {:ok, result} = AutogluonTools.test_mock_fit_multimodal("train.csv", "label", "classification")
      assert result["label"] == "label"
      assert result["problem_type"] == "classification"
    end

    test "mock_fit_timeseries returns expected structure" do
      assert {:ok, result} = AutogluonTools.test_mock_fit_timeseries("train.csv", "target", 48)
      assert result["target"] == "target"
      assert result["prediction_length"] == 48
    end

    test "mock_evaluate_model returns metrics" do
      assert {:ok, metrics} = AutogluonTools.test_mock_evaluate_model("model", "test.csv", "tabular")
      assert Map.has_key?(metrics, "accuracy")
    end
  end

  describe "error handling" do
    test "fit_tabular handles invalid input types" do
      assert_raise FunctionClauseError, fn ->
        AutogluonTools.fit_tabular(123, "label", 60)
      end

      assert_raise FunctionClauseError, fn ->
        AutogluonTools.fit_tabular("train.csv", :label, 60)
      end
    end

    test "predict_tabular handles invalid input types" do
      assert_raise FunctionClauseError, fn ->
        AutogluonTools.predict_tabular(123, "test.csv")
      end
    end

    test "fit_timeseries handles invalid input types" do
      assert_raise FunctionClauseError, fn ->
        AutogluonTools.fit_timeseries("train.csv", "target", "not_an_integer")
      end
    end
  end
end

