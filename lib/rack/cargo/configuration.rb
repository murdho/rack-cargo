# frozen_string_literal: true

module Rack
  module Cargo
    class Configuration
      attr_accessor :batch_path
      attr_accessor :processors
      attr_accessor :timeout

      def initialize
        self.batch_path = "/batch"
        self.processors = [
          ReferenceResolver,
          RequestEnvBuilder,
          RequestExecutor,
          ResponseBuilder
        ]
        self.timeout = 1 # seconds
      end
    end
  end
end
