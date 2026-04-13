# lex-llamacpp

llama.cpp inference server integration for [LegionIO](https://github.com/LegionIO/LegionIO). Connects LegionIO to a local llama.cpp server (llama-server) for chat completions, text completions, embeddings, tokenization, and server management.

## Installation

```bash
gem install lex-llamacpp
```

## Functions

### Chat
- `chat` - Generate a chat completion (POST /v1/chat/completions)
- `chat_stream` - Stream a chat completion with per-chunk callbacks (SSE)

### Completions
- `complete` - Generate a text completion (POST /v1/completions)
- `complete_stream` - Stream a text completion with per-chunk callbacks (SSE)

### Embeddings
- `embed` - Generate embeddings (POST /v1/embeddings)

### Models
- `list_models` - List loaded models (GET /v1/models)

### Health
- `health` - Server health check (GET /health)

### Tokenize
- `tokenize` - Tokenize text into tokens (POST /tokenize)
- `detokenize` - Convert tokens back to text (POST /detokenize)

### Slots
- `list_slots` - List active inference slots (GET /slots)
- `erase_slot` - Erase a specific slot (POST /slots/:id?action=erase)

## Standalone Client

```ruby
client = Legion::Extensions::Llamacpp::Client.new
# or with custom host
client = Legion::Extensions::Llamacpp::Client.new(host: 'http://remote:8080')

# Chat
result = client.chat(model: 'my-model', messages: [{ role: 'user', content: 'Hello!' }])

# Completions
result = client.complete(model: 'my-model', prompt: 'Why is the sky blue?')

# Embeddings
result = client.embed(model: 'my-model', input: 'Some text to embed')

# List models
result = client.list_models

# Health check
result = client.health

# Tokenize / Detokenize
result = client.tokenize(content: 'Hello world')
result = client.detokenize(tokens: [1, 2, 3])

# Slots
result = client.list_slots
result = client.erase_slot(id: 0)

# Streaming chat
client.chat_stream(model: 'my-model', messages: [{ role: 'user', content: 'Hello!' }]) do |event|
  case event[:type]
  when :delta then print event[:text]
  when :done  then puts "\nDone!"
  end
end

# Streaming completions
client.complete_stream(model: 'my-model', prompt: 'Tell me a story') do |event|
  print event[:text] if event[:type] == :delta
end
```

All API calls include automatic retry with exponential backoff on connection failures and timeouts.

Chat and completion responses include standardized `usage:` data:
```ruby
result = client.chat(model: 'my-model', messages: [{ role: 'user', content: 'Hello' }])
result[:usage]  # => { input_tokens: 5, output_tokens: 20, total_tokens: 25 }
```

## Requirements

- Ruby >= 3.4
- [LegionIO](https://github.com/LegionIO/LegionIO) framework
- [llama.cpp](https://github.com/ggerganov/llama.cpp) server running locally or on a remote host

## License

MIT
