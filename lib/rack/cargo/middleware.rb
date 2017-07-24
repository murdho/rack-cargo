require_relative 'response_builder.rb'
require_relative 'request_executor.rb'
require_relative 'request_env_builder.rb' # frozen_string_literal: true

require 'securerandom'

module Rack
  module Cargo
    class Middleware
      attr_accessor :app

      def initialize(app)
        self.app = app
      end

      def call(env)
        if batch_request?(env[ENV_PATH])
          # GOOD: BatchProcessor.process(env)
          # result = BatchProcessor.process(env)
          # BatchResponse.from_result(result)
          # process_batch_request(env)
          result = BatchProcessor.process(app, env)
          BatchResponse.from_result(result)
        else
          @app.call(env)
        end
      end

      module BatchResponse
        def self.from_result(from)
          response_headers = { "Content-Type" => "application/json" }

          if from[:success]
            responses = from[:responses]
            [200, response_headers, [responses.to_json]]
          else
            [422, response_headers, [{ errors: from[:error] }.to_json]]
          end
        end
      end

      # def process(env)
      #   requests = JSONPayloadRequests.from_env(env)

      #   if RequestValidator.validate(requests)
      #     responses = BatchProcessor.process(requests)
      #     BatchResponse.build(responses)
      #   else
      #     ErrorResponse.build("Invalid batch request")
      #   end
      # end

      # module ReferenceResolver
      #   REFERENCING_ENABLED = [REQUEST_PATH, REQUEST_BODY]
      #
      #   PLACEHOLDER_START = "{{\s*"
      #   PLACEHOLDER_END = "\s*}}"
      #   PLACEHOLDER_PATTERN = /#{PLACEHOLDER_START}(.*?)#{PLACEHOLDER_END}/
      #
      #   def self.call(request, state)
      #     REFERENCING_ENABLED.each do |attribute_key|
      #       element = request[attribute_key].dup
      #       element = element.to_json unless element.kind_of?(String)
      #       placeholders = element.scan(PLACEHOLDER_PATTERN).flatten
      #       placeholders.each do |placeholder|
      #         value_path = placeholder.split(".").map(&:to_s).insert(1, REQUEST_BODY)
      #         value = state[:previous_responses].dig(*value_path)
      #         next unless value
      #         replacement_regex = %r[#{PLACEHOLDER_START}#{placeholder}#{PLACEHOLDER_END}]
      #         element = element.gsub(replacement_regex, value.to_s)
      #       end
      #       if attribute_key == REQUEST_BODY
      #         request[attribute_key] = JSON.parse element
      #       else
      #         request[attribute_key] = element
      #       end
      #     end
      #   end
      # end

      # module RequestEnvBuilder
      #   def self.call(request, state)
      #     request_env = state.fetch(:env).dup # TODO: should be deep
      #     request_env[ENV_PATH] = request[REQUEST_PATH]
      #     request_env[ENV_METHOD] = request[REQUEST_METHOD]
      #     request_env[ENV_INPUT] = StringIO.new(request[REQUEST_BODY].to_json)
      #     state[:request_env] = request_env
      #   end
      # end

      # module RequestExecutor
      #   extend Rack::Cargo::RequestExecutor
      # end
      #
      # module ResponseBuilder
      #   extend Rack::Cargo::ResponseBuilder
      #   RESPONSE_NAME = "name"
      #   RESPONSE_STATUS = "status"
      #   RESPONSE_HEADERS = "headers"
      #   RESPONSE_BODY = "body"
      #
      #
      # end

      # module JSONPayloadRequests
      #   def self.from_env(env)
      #     io = env[ENV_INPUT]
      #     payload = io.read
      #     return if payload.empty?
      #
      #     json_payload = JSON.parse(payload) rescue nil
      #     return unless json_payload
      #
      #     json_payload[REQUESTS_KEY]
      #   end
      # end

      # module RequestValidator
      #   def self.validate(requests)
      #     return unless requests
      #
      #     required_keys = %w[path method body]
      #     requests.all? do |request|
      #       required_keys.all? { |key| request.key?(key) }
      #     end
      #   end
      # end

      # module BatchProcessor
      #   def self.process(app, env)
      #     requests = JSONPayloadRequests.from_env(env)
      #
      #     if RequestValidator.validate(requests)
      #       # responses = BatchProcessor.process(requests)
      #       # responses = requests.map(&method(:process_request))
      #       responses = requests.each_with_object({}) do |request, previous_responses|
      #         name = request.fetch('name', "unnamed_#{SecureRandom.hex(6)}")
      #         previous_responses[name] = process_request(app, env, request, previous_responses)
      #       end
      #       # BatchResponse.build(responses)
      #       require 'ap'; ap responses
      #       {
      #         success: true,
      #         responses: responses.values
      #       }
      #     else
      #     #   ErrorResponse.build("Invalid batch request")
      #       {
      #         success: false,
      #         error: "Invalid batch request"
      #       }
      #     end
      #
      #   end
      #
      #   def self.process_request(app, env, request, previous_responses)
      #     processors = [ReferenceResolver, RequestEnvBuilder, RequestExecutor, ResponseBuilder]
      #     initial_state = {
      #         app: app,
      #         env: env,
      #         previous_responses: previous_responses
      #     }
      #     result_state = processors.each_with_object(initial_state) do |processor, state|
      #       processor.call(request, state)
      #     end
      #     result_state[:response]
      #   end
      # end

      def batch_request?(path)
        path == BATCH_PATH
      end
    end
  end
end
