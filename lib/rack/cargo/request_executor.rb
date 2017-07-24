module Rack
  module Cargo
    module RequestExecutor
      def self.call(request, state)
        status, headers, body = state.fetch(:app).call(state.fetch(:request_env))
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
