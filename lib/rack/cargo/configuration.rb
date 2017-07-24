# frozen_string_literal: true

module Rack
  module Cargo
    class Configuration
      attr_accessor :batch_path
      attr_accessor :processors

      def initialize
        self.batch_path = "/batch"
        self.processors = [
          ReferenceResolver,
          RequestEnvBuilder,
          RequestExecutor,
          ResponseBuilder
        ]
      end
    end
  end
end
