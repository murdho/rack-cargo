# frozen_string_literal: true

module Rack
  module Cargo
    module Responses
      RESPONSE_NAME = "name"
      RESPONSE_STATUS = "status"
      RESPONSE_HEADERS = "headers"
      RESPONSE_BODY = "body"

      ERROR_MESSAGE = "Invalid batch request"

      def single_response(**args)
        {
          RESPONSE_NAME => args.fetch(:name),
          RESPONSE_STATUS => args.fetch(:status),
          RESPONSE_HEADERS => args.fetch(:headers),
          RESPONSE_BODY => JSON.parse(args.fetch(:body).join)
        }
      end

      def batch_response(responses)
        [200, response_headers, [responses.to_json]]
      end

      def error_response
        [422, response_headers, [{ errors: ERROR_MESSAGE }.to_json]]
      end

      def response_headers
        { "Content-Type" => "application/json" }
      end
    end
  end
end
