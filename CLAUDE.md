# lex-llamacpp: llama.cpp Integration for LegionIO

**Parent**: `/Users/miverso2/rubymine/legion/extensions-ai/CLAUDE.md`

## Purpose

Legion Extension that connects LegionIO to llama.cpp inference server (llama-server). Provides OpenAI-compatible chat completions, text completions, embeddings, tokenization, and server management.

**GitHub**: https://github.com/LegionIO/lex-llamacpp
**License**: MIT

## Architecture

```
Legion::Extensions::Llamacpp
├── Runners/
│   ├── Chat               # POST /v1/chat/completions (SSE streaming)
│   ├── Completions        # POST /v1/completions (SSE streaming)
│   ├── Embeddings         # POST /v1/embeddings
│   ├── Models             # GET /v1/models
│   ├── Health             # GET /health
│   ├── Tokenize           # POST /tokenize, POST /detokenize
│   └── Slots              # GET /slots, POST /slots/:id?action=erase
├── Helpers/
│   ├── Client             # Faraday connection to llama.cpp server
│   ├── Errors             # Retry logic with exponential backoff
│   └── Usage              # OpenAI-format usage extraction
└── Client                 # Standalone client class
```

## Dependencies

| Gem | Purpose |
|-----|---------|
| faraday | HTTP client for llama.cpp REST API |

## Testing

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

---

**Maintained By**: Matthew Iverson (@Esity)
