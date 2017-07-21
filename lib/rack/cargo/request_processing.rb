# frozen_string_literal: true

module Rack
  module Cargo
    module RequestProcessing
      REQUESTS_KEY = "requests"

      ENV_PATH = "PATH_INFO"
      ENV_INPUT = "rack.input"
      ENV_METHOD = "REQUEST_METHOD"

      REQUEST_NAME = "name"
      REQUEST_PATH = "path"
      REQUEST_METHOD = "method"
      REQUEST_BODY = "body"

      def process_batch_request(env)
        requests = get_requests(env[ENV_INPUT])

        if requests
          responses = []
          requests.each do |request|
            responses << process_request(request, env)
          end
          batch_response(responses)
        else
          error_response
        end
      end

      def process_request(request, env)
        request_env = build_request_env(request, env)

        status, headers, body = @app.call(request_env)
        body.close if body.respond_to?(:close)

        single_response(
          name: request[REQUEST_NAME],
          status: status,
          headers: headers,
          body: body
        )
      end

      def get_json_payload(io)
        payload = io.read
        return if payload.empty?

        JSON.parse(payload) rescue nil
      end

      def get_requests(io)
        json_payload = get_json_payload(io)
        return unless json_payload && json_payload.key?(REQUESTS_KEY)
        json_payload[REQUESTS_KEY]
      end

      def build_request_env(request, env)
        request_env = env.dup
        request_env[ENV_PATH] = request[REQUEST_PATH]
        request_env[ENV_METHOD] = request[REQUEST_METHOD]
        request_env[ENV_INPUT] = StringIO.new(request[REQUEST_BODY].to_json)
        request_env
      end
    end
  end
end
