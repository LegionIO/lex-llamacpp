# frozen_string_literal: true

require 'faraday'

module Legion
  module Extensions
    module Llamacpp
      module Helpers
        module Client
          DEFAULT_HOST = 'http://localhost:8080'

          def client(host: DEFAULT_HOST, **)
            Faraday.new(url: host) do |conn|
              conn.request :json
              conn.response :json, content_type: /\bjson$/
              conn.headers['Content-Type'] = 'application/json'
              conn.options.timeout = 300
              conn.options.open_timeout = 10
            end
          end

          def streaming_client(host: DEFAULT_HOST, **)
            Faraday.new(url: host) do |conn|
              conn.request :json
              conn.headers['Content-Type'] = 'application/json'
              conn.options.timeout = 300
              conn.options.open_timeout = 10
            end
          end
        end
      end
    end
  end
end
