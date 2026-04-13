# Changelog

## [0.1.0] - 2026-04-13

### Added
- Initial release
- Chat runner (OpenAI-compatible POST /v1/chat/completions with streaming)
- Completions runner (OpenAI-compatible POST /v1/completions with streaming)
- Embeddings runner (POST /v1/embeddings)
- Models runner (GET /v1/models)
- Health runner (GET /health)
- Tokenize runner (POST /tokenize and POST /detokenize)
- Slots runner (GET /slots and POST /slots/:id?action=erase)
- Standalone Client class with configurable host
- Faraday-based HTTP client helper with 300s timeout
- Automatic retry with exponential backoff on connection failures and timeouts
- Standardized usage extraction from OpenAI-format responses
