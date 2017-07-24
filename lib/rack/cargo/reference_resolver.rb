module Rack
  module Cargo
    module ReferenceResolver
      REFERENCING_ENABLED = [REQUEST_PATH, REQUEST_BODY]

      PLACEHOLDER_START = "{{\s*"
      PLACEHOLDER_END = "\s*}}"
      PLACEHOLDER_PATTERN = /#{PLACEHOLDER_START}(.*?)#{PLACEHOLDER_END}/

      class << self
        def call(request, state)
          REFERENCING_ENABLED.each do |attribute_key|
            element, converted_to_json = get_json_element(request, attribute_key)
            placeholders = find_placeholders(element)

            element = replace_placeholders(element, placeholders, state)
            element = JSON.parse(element) if converted_to_json

            request.store(attribute_key, element)
          end
        end

        def replace_placeholders(element, placeholders, state)
          previous_responses = state.fetch(:previous_responses)

          placeholders.each do |placeholder|
            value_path = value_path_for(placeholder)
            value = previous_responses.dig(*value_path)
            next unless value

            replacement_regex = replacement_regex_for(placeholder)
            element = element.gsub(replacement_regex, value.to_s)
          end

          element
        end

        def value_path_for(placeholder)
          placeholder.split(".").map(&:to_s).insert(1, REQUEST_BODY)
        end

        def replacement_regex_for(placeholder)
          /#{PLACEHOLDER_START}#{placeholder}#{PLACEHOLDER_END}/
        end

        def find_placeholders(element)
          element.scan(PLACEHOLDER_PATTERN).flatten
        end

        private

        def get_json_element(request, attribute_key)
          element_copy = request.fetch(attribute_key).dup

          if element_copy.kind_of?(String)
            [element_copy, false]
          else
            [element_copy.to_json, true]
          end
        end
      end
    end
  end
end
