module Rack
  module Cargo
    module BatchProcessor
      def self.process(app, env)
        requests = JSONPayloadRequests.from_env(env)

        if RequestValidator.validate(requests)
          # responses = BatchProcessor.process(requests)
          # responses = requests.map(&method(:process_request))
          responses = requests.each_with_object({}) do |request, previous_responses|
            name = request.fetch('name', "unnamed_#{SecureRandom.hex(6)}")
            previous_responses[name] = process_request(app, env, request, previous_responses)
          end
          # BatchResponse.build(responses)
          require 'ap'; ap responses
          {
              success: true,
              responses: responses.values
          }
        else
          #   ErrorResponse.build("Invalid batch request")
          {
              success: false,
              error: "Invalid batch request"
          }
        end

      end

      def self.process_request(app, env, request, previous_responses)
        processors = [ReferenceResolver, RequestEnvBuilder, RequestExecutor, ResponseBuilder]
        initial_state = {
            app: app,
            env: env,
            previous_responses: previous_responses
        }
        result_state = processors.each_with_object(initial_state) do |processor, state|
          processor.call(request, state)
        end
        result_state[:response]
      end
    end
  end
end