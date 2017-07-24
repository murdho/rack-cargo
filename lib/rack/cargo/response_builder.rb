module Rack
  module Cargo
    module ResponseBuilder
      RESPONSE_NAME = "name"
      RESPONSE_STATUS = "status"
      RESPONSE_HEADERS = "headers"
      RESPONSE_BODY = "body"

      def self.call(request, state)
        app_response = state.fetch(:app_response)

        name = request.fetch('name', "unnamed_#{SecureRandom.hex(6)}")

        state[:response] = {
            RESPONSE_NAME => name,
            RESPONSE_STATUS => app_response.fetch(:status),
            RESPONSE_HEADERS => app_response.fetch(:headers),
            RESPONSE_BODY => JSON.parse(app_response.fetch(:body).join)
        }
      end
    end
  end
end
