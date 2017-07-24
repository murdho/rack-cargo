module Rack
  module Cargo
    class Configuration
      attr_accessor :batch_path

      def initialize
        self.batch_path = "/batch"
      end
    end
  end
end
