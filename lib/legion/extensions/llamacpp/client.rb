# frozen_string_literal: true

require_relative 'helpers/client'
require_relative 'runners/chat'
require_relative 'runners/completions'
require_relative 'runners/embeddings'
require_relative 'runners/models'
require_relative 'runners/health'
require_relative 'runners/tokenize'
require_relative 'runners/slots'

module Legion
  module Extensions
    module Llamacpp
      class Client
        include Helpers::Client
        include Runners::Chat
        include Runners::Completions
        include Runners::Embeddings
        include Runners::Models
        include Runners::Health
        include Runners::Tokenize
        include Runners::Slots

        attr_reader :opts

        def initialize(host: Helpers::Client::DEFAULT_HOST, **)
          @opts = { host: host }.compact
        end

        def client(**override)
          super(**@opts, **override)
        end

        def streaming_client(**override)
          super(**@opts, **override)
        end
      end
    end
  end
end
