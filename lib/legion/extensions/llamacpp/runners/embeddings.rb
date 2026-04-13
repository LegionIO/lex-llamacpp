# frozen_string_literal: true

require 'legion/extensions/llamacpp/helpers/client'
require 'legion/extensions/llamacpp/helpers/errors'

module Legion
  module Extensions
    module Llamacpp
      module Runners
        module Embeddings
          extend Legion::Extensions::Llamacpp::Helpers::Client

          def embed(model:, input:, **)
            body = { model: model, input: input }.compact
            response = Helpers::Errors.with_retry { client(**).post('/v1/embeddings', body) }
            { result: response.body, status: response.status }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)
        end
      end
    end
  end
end
