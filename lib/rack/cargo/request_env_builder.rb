# frozen_string_literal: true

require "rack/cargo/core_ext/deep_dup"

module Rack
  module Cargo
    module RequestEnvBuilder
      def self.call(request, state)
        request_env = state.fetch(:env).deep_dup
        request_env[ENV_PATH] = request[REQUEST_PATH]
        request_env[ENV_METHOD] = request[REQUEST_METHOD]
        request_env[ENV_INPUT] = StringIO.new(request[REQUEST_BODY].to_json)
        state[:request_env] = request_env
      end
    end
  end
end
