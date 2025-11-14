# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule AutogluonMcp.AutogluonValidator do
  @moduledoc """
  Validates AutoGluon availability at startup.
  Crashes if AutoGluon is not available (fail-fast strategy).
  """

  require Logger

  use GenServer

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    # Validate AutoGluon availability
    case validate_autogluon() do
      :ok ->
        Logger.info("AutoGluon validation successful")
        {:ok, :validated}

      {:error, reason} ->
        Logger.error("AutoGluon validation failed: #{inspect(reason)}")
        # Crash the process - supervisor will handle it
        {:stop, {:shutdown, "AutoGluon not available: #{inspect(reason)}"}}
    end
  end

  defp validate_autogluon do
    # Step 1: Ensure Pythonx is started
    case Application.ensure_all_started(:pythonx) do
      {:error, reason} ->
        {:error, {:pythonx_start_failed, reason}}

      {:ok, _} ->
        # Step 2: Check Python availability
        case check_python_availability() do
          :ok ->
            # Step 3: Check AutoGluon import
            check_autogluon_import()

          error ->
            error
        end
    end
  rescue
    exception ->
      {:error, {:exception, Exception.message(exception)}}
  end

  defp check_python_availability do
    # Use /dev/null or NUL to suppress Python's output
    null_device = get_null_device()

    case Pythonx.eval("1 + 1", %{}, stdout_device: null_device, stderr_device: null_device) do
      {result, _globals} ->
        case Pythonx.decode(result) do
          2 -> :ok
          _ -> {:error, :python_eval_failed}
        end

      _ ->
        {:error, :python_eval_failed}
    end
  rescue
    exception ->
      {:error, {:python_exception, Exception.message(exception)}}
  end

  defp check_autogluon_import do
    null_device = get_null_device()

    code = """
    result = "ok"
    try:
        import autogluon
        import autogluon.tabular
        import autogluon.multimodal
        import autogluon.timeseries
    except ImportError as e:
        result = f"import_error: {str(e)}"
    except Exception as e:
        result = f"error: {str(e)}"
    result
    """

    case Pythonx.eval(code, %{}, stdout_device: null_device, stderr_device: null_device) do
      {result, _globals} ->
        case Pythonx.decode(result) do
          "ok" -> :ok
          error_msg when is_binary(error_msg) -> {:error, {:autogluon_import_failed, error_msg}}
          _ -> {:error, :autogluon_import_failed}
        end

      _ ->
        {:error, :autogluon_import_failed}
    end
  rescue
    exception ->
      {:error, {:autogluon_exception, Exception.message(exception)}}
  end

  defp get_null_device do
    case :os.type() do
      {:unix, _} -> File.open!("/dev/null", [:write])
      {:win32, _} -> File.open!("NUL", [:write])
      _ -> :stdio
    end
  end
end
