# frozen_string_literal: true

require 'legion/extensions/llamacpp/helpers/client'
require 'legion/extensions/llamacpp/helpers/errors'

module Legion
  module Extensions
    module Llamacpp
      module Runners
        module Slots
          extend Legion::Extensions::Llamacpp::Helpers::Client

          def list_slots(**)
            response = Helpers::Errors.with_retry { client(**).get('/slots') }
            { result: response.body, status: response.status }
          end

          def erase_slot(id:, **)
            response = Helpers::Errors.with_retry { client(**).post("/slots/#{id}?action=erase") }
            { result: response.body, status: response.status }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)
        end
      end
    end
  end
end
