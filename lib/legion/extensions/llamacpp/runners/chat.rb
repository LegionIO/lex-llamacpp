# frozen_string_literal: true

require 'json'
require 'legion/extensions/llamacpp/helpers/client'
require 'legion/extensions/llamacpp/helpers/errors'
require 'legion/extensions/llamacpp/helpers/usage'

module Legion
  module Extensions
    module Llamacpp
      module Runners
        module Chat
          extend Legion::Extensions::Llamacpp::Helpers::Client

          def chat(model:, messages:, temperature: nil, max_tokens: nil, top_p: nil, stream: false, tools: nil, **)
            body = { model: model, messages: messages, temperature: temperature, max_tokens: max_tokens,
                     top_p: top_p, stream: stream, tools: tools }.compact
            response = Helpers::Errors.with_retry { client(**).post('/v1/chat/completions', body) }
            { result: response.body, usage: Helpers::Usage.from_response(response.body), status: response.status }
          end

          def chat_stream(model:, messages:, temperature: nil, max_tokens: nil, top_p: nil, tools: nil, **, &block)
            body = { model: model, messages: messages, temperature: temperature, max_tokens: max_tokens,
                     top_p: top_p, stream: true, tools: tools }.compact
            accumulated = +''
            usage_data = nil
            buffer = +''

            Helpers::Errors.with_retry do
              streaming_client(**).post('/v1/chat/completions', body) do |req|
                req.options.on_data = proc do |chunk, _size|
                  buffer << chunk
                  while (idx = buffer.index("\n\n"))
                    line = buffer.slice!(0, idx + 2).strip
                    next if line.empty?
                    next unless line.start_with?('data: ')

                    payload = line.sub('data: ', '')
                    if payload == '[DONE]'
                      block&.call({ type: :done, data: {} })
                      next
                    end

                    parsed = ::JSON.parse(payload)
                    text = parsed.dig('choices', 0, 'delta', 'content') || ''
                    usage_data = parsed['usage'] if parsed.key?('usage')
                    unless text.empty?
                      accumulated << text
                      block&.call({ type: :delta, text: text })
                    end
                  end
                end
              end
            end

            usage = Helpers::Usage.from_response(usage_data ? { 'usage' => usage_data } : nil)
            { result: accumulated, usage: usage, status: 200 }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)
        end
      end
    end
  end
end
