# frozen_string_literal: true

module Rack
  module Cargo
    class Middleware
      include Responses
      include RequestProcessing

      attr_accessor :app

      BATCH_PATH = "/batch"
      ENV_PATH = "PATH_INFO"

      def initialize(app)
        self.app = app
      end

      def call(env)
        if batch_request?(env[ENV_PATH])
          process_batch_request(env)
        else
          @app.call(env)
        end
      end

      def batch_request?(path)
        path == BATCH_PATH
      end
    end
  end
end
