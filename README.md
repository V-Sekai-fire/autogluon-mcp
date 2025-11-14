# AutoGluon MCP

[![smithery badge](https://smithery.ai/badge/@V-Sekai-fire/autogluon-mcp)](https://smithery.ai/server/@V-Sekai-fire/autogluon-mcp)

An Elixir-based MCP (Model Context Protocol) server that provides machine learning capabilities using AutoGluon.

## Features

- **Tabular Prediction**: Train and predict with tabular data for classification and regression
- **Multimodal Learning**: Support for text, image, and combined text+image data
- **Time Series Forecasting**: Forecast future values in time series data
- **Model Evaluation**: Evaluate trained models on test data
- **Easy Integration**: Simple API for training, prediction, and evaluation

## Quick Start

### Prerequisites

- Elixir 1.18+
- OpenSSL development libraries

> **Note**: Python 3.8+ and AutoGluon are automatically installed during compilation via PythonX.

### Installation

```bash
git clone https://github.com/V-Sekai-fire/autogluon-mcp.git
cd autogluon-mcp
mix deps.get
mix compile
```

## Usage

### STDIO Transport (Default)

For local development:

```bash
mix mcp.server
```

Or using release:

```bash
./_build/prod/rel/autogluon_mcp/bin/autogluon_mcp start
```

### HTTP Transport

For web deployments (e.g., Smithery):

```bash
PORT=8081 MIX_ENV=prod ./_build/prod/rel/autogluon_mcp/bin/autogluon_mcp start
```

**Endpoints:**

- `POST /` - JSON-RPC 2.0 MCP requests
- `GET /sse` - Server-Sent Events for streaming
- `GET /health` - Health check

### Docker

```bash
docker build -t autogluon-mcp .
docker run -d -p 8081:8081 --name autogluon-mcp autogluon-mcp
```

### Available Tools

- `autogluon_fit_tabular` - Train a tabular predictor on training data
- `autogluon_predict_tabular` - Make predictions using a trained tabular model
- `autogluon_fit_multimodal` - Train a multimodal predictor (text/image/tabular)
- `autogluon_fit_timeseries` - Train a time series predictor for forecasting
- `autogluon_evaluate_model` - Evaluate a trained model on test data

### Example

**STDIO:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "autogluon_fit_tabular",
    "arguments": {
      "train_data_path": "train.csv",
      "label": "class",
      "time_limit": 60
    }
  }
}
```

**HTTP:**

```bash
curl -X POST http://localhost:8081/ \
  -H "Content-Type: application/json" \
  -H "mcp-protocol-version: 2025-06-18" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "autogluon_fit_tabular", "arguments": {"train_data_path": "train.csv", "label": "class"}}}'
```

## Configuration

**Optional MCP Configuration:**

The server supports optional configuration during initialization:

- `timeout_ms` (integer, optional): Maximum time in milliseconds allowed for AutoGluon operations. If not provided, no timeout is enforced. Must be between 100 and 300000. Prevents resource exhaustion and DoS attacks.
  - Example values: `5000`, `10000`, `30000`

**Environment Variables:**

- `MCP_TRANSPORT` - Transport type (`"http"` or `"stdio"`)
- `PORT` - HTTP server port (default: 8081)
- `HOST` - HTTP server host (default: `0.0.0.0` if PORT set, else `localhost`)
- `MIX_ENV` - Environment (`prod`, `dev`, `test`)
- `ELIXIR_ERL_OPTIONS` - Erlang options (set to `"+fnu"` for UTF-8)

**Transport Selection:**

1. If `MCP_TRANSPORT` is set, use that transport
2. If `PORT` is set, use HTTP transport
3. Otherwise, use STDIO transport (default)

## AutoGluon Capabilities

### Tabular Prediction

Train models on structured data for classification and regression tasks:

```python
from autogluon.tabular import TabularDataset, TabularPredictor

train_data = TabularDataset('train.csv')
predictor = TabularPredictor(label='class').fit(train_data)
predictions = predictor.predict(test_data)
```

### Multimodal Learning

Support for text, image, and combined data types:

- Text classification
- Image classification
- Named Entity Recognition (NER)
- Object detection
- Semantic matching

### Time Series Forecasting

Forecast future values in time series:

```python
from autogluon.timeseries import TimeSeriesDataFrame, TimeSeriesPredictor

data = TimeSeriesDataFrame('timeseries.csv')
predictor = TimeSeriesPredictor(target='target', prediction_length=48).fit(data)
predictions = predictor.predict(data)
```

## Troubleshooting

**Python/AutoGluon not found**: The build process installs Python and AutoGluon automatically via PythonX. Run `mix clean && mix compile` if issues persist.

**Port already in use**: Change `PORT` environment variable or stop conflicting services.

**Compilation errors**: Run `mix deps.get && mix clean && mix compile`.

**Debug mode**: Use `MIX_ENV=dev mix mcp.server` for verbose logging.

**Memory issues**: AutoGluon can be memory-intensive. Consider setting time limits or using smaller datasets for testing.

## License

MIT License - see LICENSE.md for details.

## Contributing

See [DEVELOPING.md](DEVELOPING.md) for development setup and contribution guidelines.

## References

- [AutoGluon Documentation](https://auto.gluon.ai/stable/index.html)
- [PythonX Documentation](https://hex.pm/packages/pythonx)
- [MCP Protocol](https://modelcontextprotocol.io/)

