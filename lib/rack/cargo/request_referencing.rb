# frozen_string_literal: true

module Rack
  module Cargo
    module RequestReferencing
      # ReferenceResolver
      PLACEHOLDER_START = "{{\s*"
      PLACEHOLDER_END = "\s*}}"
      PLACEHOLDER_PATTERN = /#{PLACEHOLDER_START}(.*?)#{PLACEHOLDER_END}/

      def resolve_references(unresolved, responses)
        placeholders = unresolved.scan(PLACEHOLDER_PATTERN).flatten
        resolved = unresolved.dup

        placeholders.each do |placeholder|
          value = get_value(placeholder, responses)
          next unless value

          replacement_regex = get_replacement_regex(placeholder)
          resolved = resolved.gsub(replacement_regex, value.to_s)
        end

        resolved
      end

      def get_value(placeholder, responses)
        value_path = placeholder.split(".").map(&:to_s).insert(1, REQUEST_BODY)
        responses.dig(*value_path)
      end

      def get_replacement_regex(placeholder)
        %r[#{PLACEHOLDER_START}#{placeholder}#{PLACEHOLDER_END}]
      end

      # def perform_replacements(unrendered, responses)
      #   placeholders = unrendered.scan(PLACEHOLDER_PATTERN).flatten
      #   rendered = unrendered.dup

      #   placeholders.each do |placeholder|
      #     value_path = placeholder.split(".").map(&:to_s).insert(1, REQUEST_BODY)
      #     value = responses.dig(*value_path)
      #     next unless value
      #     regexp = [PLACEHOLDER_START, placeholder, PLACEHOLDER_END].join
      #     rendered = rendered.gsub(/#{regexp}/, value.to_s)
      #   end

      #   rendered
      # end
    end
  end
end
