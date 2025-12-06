# AutoGluon MCP Agents

This document describes all available agents (tools) provided by the AutoGluon MCP Server.

> **⚠️ DEVELOPMENT RELEASE**: This is a development release. Not for production use.

## Overview

The AutoGluon MCP Server provides machine learning capabilities through the Model Context Protocol (MCP). It exposes tools for training, prediction, and evaluation across three main domains:

- **Tabular Prediction**: Classification and regression on structured data
- **Multimodal Learning**: Text, image, and combined text+image data
- **Time Series Forecasting**: Forecasting future values in time series data

## Available Tools

### 1. `autogluon_fit_tabular`

Trains an AutoGluon tabular predictor on training data for classification or regression tasks.

**Parameters:**
- `train_data_path` (string, required): Path to training CSV file or JSON string of training data
- `label` (string, required): Name of the label column to predict
- `time_limit` (integer, optional): Optional time limit in seconds for training (default: no limit)

**Returns:**
- Training summary including:
  - `label`: The label column used
  - `status`: Training status (typically "completed")
  - `best_model`: Name of the best performing model
  - `fit_summary`: Detailed fit summary string
  - `num_models`: Number of models trained

**Example:**
```json
{
  "name": "autogluon_fit_tabular",
  "arguments": {
    "train_data_path": "train.csv",
    "label": "class",
    "time_limit": 60
  }
}
```

**Use Cases:**
- Classification tasks (binary and multi-class)
- Regression tasks
- Feature importance analysis
- Ensemble model training

---

### 2. `autogluon_predict_tabular`

Makes predictions using a trained tabular predictor.

**Parameters:**
- `model_path` (string, required): Path to saved model directory
- `test_data_path` (string, required): Path to test CSV file or JSON string of test data

**Returns:**
- Array of predictions (one per row in test data)

**Example:**
```json
{
  "name": "autogluon_predict_tabular",
  "arguments": {
    "model_path": "./models/tabular_model",
    "test_data_path": "test.csv"
  }
}
```

**Tool Annotations:**
- `readOnlyHint`: true
- `idempotentHint`: true

---

### 3. `autogluon_fit_multimodal`

Trains an AutoGluon multimodal predictor for text, image, or combined text+image data.

**Parameters:**
- `train_data_path` (string, required): Path to training data (CSV/Parquet) or JSON string
- `label` (string, required): Name of the label column
- `problem_type` (string, optional): Problem type - "classification", "regression", "ner", etc. (default: "classification")

**Returns:**
- Training summary including:
  - `label`: The label column used
  - `problem_type`: The problem type specified
  - `status`: Training status
  - `fit_summary`: Detailed fit summary string

**Example:**
```json
{
  "name": "autogluon_fit_multimodal",
  "arguments": {
    "train_data_path": "multimodal_train.csv",
    "label": "category",
    "problem_type": "classification"
  }
}
```

**Use Cases:**
- Text classification
- Image classification
- Named Entity Recognition (NER)
- Object detection
- Semantic matching
- Combined text+image tasks

---

### 4. `autogluon_fit_timeseries`

Trains an AutoGluon time series predictor for forecasting future values.

**Parameters:**
- `train_data_path` (string, required): Path to training CSV file or JSON string
- `target` (string, required): Name of the target column to forecast
- `prediction_length` (integer, required): Number of time steps to predict into the future

**Returns:**
- Training summary including:
  - `target`: The target column used
  - `prediction_length`: The prediction length specified
  - `status`: Training status
  - `fit_summary`: Detailed fit summary string

**Example:**
```json
{
  "name": "autogluon_fit_timeseries",
  "arguments": {
    "train_data_path": "timeseries_train.csv",
    "target": "sales",
    "prediction_length": 48
  }
}
```

**Use Cases:**
- Time series forecasting
- Anomaly detection
- Demand prediction
- Financial forecasting

---

### 5. `autogluon_evaluate_model`

Evaluates a trained AutoGluon model on test data.

**Parameters:**
- `model_path` (string, required): Path to saved model directory
- `test_data_path` (string, required): Path to test data file
- `model_type` (string, required): Type of model - must be one of: "tabular", "multimodal", "timeseries"

**Returns:**
- Dictionary of evaluation metrics (varies by model type):
  - **Tabular/Multimodal**: Typically includes accuracy, F1 score, etc.
  - **Time Series**: Typically includes MAE (Mean Absolute Error), MSE (Mean Squared Error), etc.
  - `status`: Evaluation status

**Example:**
```json
{
  "name": "autogluon_evaluate_model",
  "arguments": {
    "model_path": "./models/tabular_model",
    "test_data_path": "test.csv",
    "model_type": "tabular"
  }
}
```

**Tool Annotations:**
- `readOnlyHint`: true
- `idempotentHint`: true

---

## Prompts

### `autogluon_helper`

A helper prompt that guides users on how to perform machine learning tasks with AutoGluon.

**Arguments:**
- `task_type` (string, required): The type of ML task - "tabular", "multimodal", or "timeseries"
- `operation` (string, required): The operation to perform - "fit", "predict", or "evaluate"
- `data_path` (string, optional): Path to data file or JSON string
- `label` (string, optional): Name of the label/target column
- `model_path` (string, optional): Path to saved model directory (for predict/evaluate)

**Example:**
```json
{
  "name": "autogluon_helper",
  "arguments": {
    "task_type": "tabular",
    "operation": "fit",
    "data_path": "train.csv",
    "label": "class"
  }
}
```

---

## Resources

### `autogluon://examples`

Provides example datasets and usage patterns for AutoGluon.

**Content:**
- Example code snippets for tabular, multimodal, and time series tasks
- Use case descriptions
- Quick start guides

**Access:**
- Resource URI: `autogluon://examples`
- MIME type: `application/json`

---

## Configuration

The server supports optional configuration during initialization:

### `timeout_ms` (optional)

Maximum time in milliseconds allowed for AutoGluon operations. If not provided, no timeout is enforced.

- **Type**: integer
- **Range**: 100 to 300,000 milliseconds
- **Purpose**: Prevents resource exhaustion and DoS attacks
- **Examples**: 5000 (5 seconds), 10000 (10 seconds), 30000 (30 seconds)

**Example Configuration:**
```json
{
  "timeout_ms": 30000
}
```

---

## Data Format Support

### Input Data Formats

All tools support the following input formats:

1. **CSV files**: `.csv` extension
   - Example: `"train_data_path": "data/train.csv"`

2. **JSON strings**: Inline JSON data
   - Example: `"train_data_path": "{\"col1\": [1,2,3], \"col2\": [4,5,6]}"`

3. **Parquet files** (multimodal only): `.parquet` extension
   - Example: `"train_data_path": "data/train.parquet"`

### Output Format

All tools return JSON-encoded results that can be parsed by MCP clients.

---

## Workflow Examples

### Complete Tabular Workflow

1. **Train a model:**
   ```json
   {
     "name": "autogluon_fit_tabular",
     "arguments": {
       "train_data_path": "train.csv",
       "label": "target",
       "time_limit": 120
     }
   }
   ```

2. **Make predictions:**
   ```json
   {
     "name": "autogluon_predict_tabular",
     "arguments": {
       "model_path": "./models/tabular_model",
       "test_data_path": "test.csv"
     }
   }
   ```

3. **Evaluate the model:**
   ```json
   {
     "name": "autogluon_evaluate_model",
     "arguments": {
       "model_path": "./models/tabular_model",
       "test_data_path": "test.csv",
       "model_type": "tabular"
     }
   }
   ```

### Multimodal Classification Workflow

1. **Train a multimodal model:**
   ```json
   {
     "name": "autogluon_fit_multimodal",
     "arguments": {
       "train_data_path": "multimodal_train.csv",
       "label": "category",
       "problem_type": "classification"
     }
   }
   ```

2. **Evaluate the model:**
   ```json
   {
     "name": "autogluon_evaluate_model",
     "arguments": {
       "model_path": "./models/multimodal_model",
       "test_data_path": "test.csv",
       "model_type": "multimodal"
     }
   }
   ```

### Time Series Forecasting Workflow

1. **Train a time series model:**
   ```json
   {
     "name": "autogluon_fit_timeseries",
     "arguments": {
       "train_data_path": "timeseries_train.csv",
       "target": "sales",
       "prediction_length": 48
     }
   }
   ```

2. **Evaluate the model:**
   ```json
   {
     "name": "autogluon_evaluate_model",
     "arguments": {
       "model_path": "./models/timeseries_model",
       "test_data_path": "test.csv",
       "model_type": "timeseries"
     }
   }
   ```

---

## Error Handling

All tools return structured error responses:

- **Success**: `{:ok, result}` - Returns the operation result
- **Error**: `{:error, reason}` - Returns an error message string

Common error scenarios:
- Invalid file paths
- Missing required columns
- AutoGluon import failures
- Python execution errors
- Timeout errors (if configured)

---

## Implementation Details

### Architecture

- **Language**: Elixir
- **ML Framework**: AutoGluon (Python)
- **Bridge**: PythonX for Elixir-Python interop
- **Protocol**: MCP (Model Context Protocol)
- **Transports**: STDIO (default) and HTTP

### Tool Execution Flow

1. MCP client sends tool call request
2. `NativeService` receives and validates parameters
3. `AutogluonTools` module executes Python code via PythonX
4. AutoGluon performs the ML operation
5. Results are encoded as JSON and returned to client

### Validation

- `AutogluonValidator` ensures AutoGluon is available at startup
- Parameter validation via JSON Schema
- Type checking in Elixir function guards
- Runtime error handling with descriptive messages

---

## References

- [AutoGluon Documentation](https://auto.gluon.ai/stable/index.html)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [PythonX Documentation](https://hex.pm/packages/pythonx)

---

## License

MIT License - see LICENSE.md for details.
