# frozen_string_literal: true

module Rack
  module Cargo
    module RequestValidator
      REQUIRED_KEYS = [
        REQUEST_PATH,
        REQUEST_METHOD,
        REQUEST_BODY
      ].freeze

      def self.validate(requests)
        return unless requests

        requests.all? do |request|
          REQUIRED_KEYS.all? { |key| request.key?(key) }
        end
      end
    end
  end
end
