module Rack
  module Cargo
    module BatchProcessor
      ERROR_INVALID_BATCH = "Invalid batch request"

      class << self
        def process(app, env)
          requests = JSONPayloadRequests.from_env(env)

          if RequestValidator.validate(requests)
            results = process_requests(app, env, requests)
            success(results)
          else
            failure([ERROR_INVALID_BATCH])
          end
        end

        private

        def process_requests(app, env, requests)
          previous_responses = {}

          requests.each do |request|
            response = process_request(
                app,
                env,
                request,
                previous_responses
            )
            previous_responses[response.fetch("name")] = response
          end

          previous_responses.values
        end

        def process_request(app, env, request, previous_responses)
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

        def success(responses)
          { success: true, responses: responses }
        end

        def failure(errors)
          { success: false, errors: errors }
        end

        def processors
          [ReferenceResolver, RequestEnvBuilder, RequestExecutor, ResponseBuilder]
        end
      end
    end
  end
end