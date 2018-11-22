# frozen_string_literal: true

require "rack/cargo/core_ext/deep_dup"

module Rack
  module Cargo
    module RequestEnvBuilder
      class << self
        def call(request, state)
          request_env = state.fetch(:env).deep_dup

          path, query_string = request[REQUEST_PATH].split("?", 2)
          request_env[ENV_PATH] = path
          request_env[ENV_QUERY_STRING] = query_string || ""
          request_env[ENV_METHOD] = request[REQUEST_METHOD]
          request_env[ENV_INPUT] = StringIO.new(
            io_input_from_request_body(request[REQUEST_BODY])
          )

          state[:request_env] = request_env
        end

        private

        # Returns request_body as JSON if it's not nil,
        # otherwise returns empty string.
        def io_input_from_request_body(request_body)
          return "" if request_body.nil?
          request_body.to_json
        end
      end
    end
  end
end
