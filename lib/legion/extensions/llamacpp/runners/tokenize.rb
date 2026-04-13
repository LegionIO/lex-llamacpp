# frozen_string_literal: true

require 'legion/extensions/llamacpp/helpers/client'
require 'legion/extensions/llamacpp/helpers/errors'

module Legion
  module Extensions
    module Llamacpp
      module Runners
        module Tokenize
          extend Legion::Extensions::Llamacpp::Helpers::Client

          def tokenize(content:, **)
            body = { content: content }
            response = Helpers::Errors.with_retry { client(**).post('/tokenize', body) }
            { result: response.body, status: response.status }
          end

          def detokenize(tokens:, **)
            body = { tokens: tokens }
            response = Helpers::Errors.with_retry { client(**).post('/detokenize', body) }
            { result: response.body, status: response.status }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)
        end
      end
    end
  end
end
