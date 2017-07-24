module Rack
  module Cargo
    module RequestValidator
      def self.validate(requests)
        return unless requests

        required_keys = %w[path method body]
        requests.all? do |request|
          required_keys.all? { |key| request.key?(key) }
        end
      end
    end
  end
end