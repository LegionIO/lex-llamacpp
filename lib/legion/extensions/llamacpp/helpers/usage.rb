# frozen_string_literal: true

module Legion
  module Extensions
    module Llamacpp
      module Helpers
        module Usage
          EMPTY_USAGE = {
            input_tokens:  0,
            output_tokens: 0,
            total_tokens:  0
          }.freeze

          module_function

          def from_response(body)
            return EMPTY_USAGE.dup unless body.is_a?(Hash)

            usage = body['usage']
            return EMPTY_USAGE.dup unless usage.is_a?(Hash)

            {
              input_tokens:  usage['prompt_tokens'] || 0,
              output_tokens: usage['completion_tokens'] || 0,
              total_tokens:  usage['total_tokens'] || 0
            }
          end
        end
      end
    end
  end
end
