# frozen_string_literal: true

require 'legion/extensions/llamacpp/version'
require 'legion/extensions/llamacpp/helpers/client'
require 'legion/extensions/llamacpp/helpers/errors'
require 'legion/extensions/llamacpp/helpers/usage'
require 'legion/extensions/llamacpp/runners/chat'
require 'legion/extensions/llamacpp/runners/completions'
require 'legion/extensions/llamacpp/runners/embeddings'
require 'legion/extensions/llamacpp/runners/models'
require 'legion/extensions/llamacpp/runners/health'
require 'legion/extensions/llamacpp/runners/tokenize'
require 'legion/extensions/llamacpp/runners/slots'
require 'legion/extensions/llamacpp/client'

module Legion
  module Extensions
    module Llamacpp
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
