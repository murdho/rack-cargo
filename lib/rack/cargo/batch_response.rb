# frozen_string_literal: true

module Rack
  module Cargo
    module BatchResponse
      class << self
        def from_result(result)
          if result[:success]
            respond_with(200, result[:responses])
          else
            respond_with(422, errors: result[:errors])
          end
        end

        private

        def respond_with(status, body)
          response_headers = { "Content-Type" => "application/json" }
          [status, response_headers, [body.to_json]]
        end
      end
    end
  end
end
