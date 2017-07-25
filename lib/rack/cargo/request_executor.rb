# frozen_string_literal: true

module Rack
  module Cargo
    module RequestExecutor
      class << self
        def call(_request, state)
          app = state.fetch(:app)
          request_env = state.fetch(:request_env)

          status, headers, body = with_timeout(Rack::Cargo.config.timeout) do
            app.call(request_env)
          end

          body.close if body.respond_to?(:close)

          state[:app_response] = {
            status: status,
            headers: headers,
            body: body
          }
        end

        def with_timeout(seconds, &block)
          Timeout.timeout(seconds, &block)
        rescue Timeout::Error
          timeout_response
        end

        def timeout_response
          [504, {}, ["{}"]]
        end
      end
    end
  end
end
