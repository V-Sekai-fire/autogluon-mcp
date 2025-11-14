# Contributing to AutoGluon MCP

Thank you for your interest in contributing to AutoGluon MCP! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/autogluon-mcp.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes: `mix test`
6. Format your code: `mix format`
7. Submit a pull request

## Development Setup

```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Run linter
mix credo

# Run formatter
mix format

# Run dialyzer (type checking)
mix dialyzer
```

## Code Style

- Follow the Elixir style guide
- Run `mix format` before committing
- Use `mix credo` to check for code quality issues
- Write tests for new functionality
- Update documentation as needed

## Testing

- Write tests for all new features
- Ensure all tests pass: `mix test`
- Aim for at least 70% test coverage
- Test both success and error cases

## Pull Request Process

1. Update the README.md with details of changes if needed
2. Update the CHANGELOG.md if applicable
3. Ensure all tests pass
4. Ensure code is formatted
5. Create a pull request with a clear description
6. Link any related issues

## Commit Messages

- Use clear, descriptive commit messages
- Reference issue numbers when applicable
- Follow conventional commit format when possible:
  - `feat: add new feature`
  - `fix: fix bug`
  - `docs: update documentation`
  - `test: add tests`
  - `refactor: refactor code`

## Questions?

Feel free to open an issue for any questions or concerns.

