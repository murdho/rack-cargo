module Rack
  module Cargo
    class Middleware
      attr_accessor :app

      def initialize(app)
        self.app = app
      end

      def call(env)
        if batch_request?(env[ENV_PATH])
          result = BatchProcessor.process(app, env)
          BatchResponse.from_result(result)
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
