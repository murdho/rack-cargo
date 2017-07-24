# frozen_string_literal: true

module Rack
  module Cargo
    module RequestProcessing
      def process_batch_request(env)
        json_payload = get_json_payload(env[ENV_INPUT])
        requests = get_requests(json_payload)

        if requests_valid?(requests)
          responses = {}
          requests.each do |request|
            name = request[REQUEST_NAME]
            responses[name] = process_request(request, env, responses)
          end
          require 'ap'; ap responses
          batch_response(responses.values)
        else
          error_response
        end
      end

      def requests_valid?(requests)
        return false unless requests

        required_keys = %w[path method body]
        requests.all? do |request|
           required_keys.all? { |key| request.key?(key) }
        end
      end

      def process_request(request, env, responses)
        replaced_path = resolve_references(request[REQUEST_PATH], responses)
        request[REQUEST_PATH] = replaced_path

        replaced_body = JSON.parse(resolve_references(request[REQUEST_BODY].to_json, responses))
        request[REQUEST_BODY] = replaced_body

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

      def resolve_references(string, responses)
        string
      end

      def get_json_payload(io)
        payload = io.read
        return if payload.empty?

        JSON.parse(payload) rescue nil
      end

      def get_requests(json_payload)
        json_payload && json_payload[REQUESTS_KEY]
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
