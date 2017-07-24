module Rack
  module Cargo
    module ReferenceResolver
      REFERENCING_ENABLED = [REQUEST_PATH, REQUEST_BODY]

      PLACEHOLDER_START = "{{\s*"
      PLACEHOLDER_END = "\s*}}"
      PLACEHOLDER_PATTERN = /#{PLACEHOLDER_START}(.*?)#{PLACEHOLDER_END}/

      def self.call(request, state)
        REFERENCING_ENABLED.each do |attribute_key|
          element = request[attribute_key].dup
          conversion_needed = !element.kind_of?(String)
          element = element.to_json if conversion_needed
          placeholders = element.scan(PLACEHOLDER_PATTERN).flatten
          placeholders.each do |placeholder|
            value_path = placeholder.split(".").map(&:to_s).insert(1, REQUEST_BODY)
            value = state[:previous_responses].dig(*value_path)
            next unless value
            replacement_regex = %r[#{PLACEHOLDER_START}#{placeholder}#{PLACEHOLDER_END}]
            element = element.gsub(replacement_regex, value.to_s)
          end
          if conversion_needed
            request[attribute_key] = JSON.parse element
          else
            request[attribute_key] = element
          end
        end
      end
    end
  end
end
