# frozen_string_literal: true

module Rack
  module Cargo
    module RequestExecutor
      def self.call(_request, state)
        app = state.fetch(:app)
        request_env = state.fetch(:request_env)

        status, headers, body = app.call(request_env)
        body.close if body.respond_to?(:close)

        state[:app_response] = {
          status: status,
          headers: headers,
          body: body
        }
      end
    end
  end
end
