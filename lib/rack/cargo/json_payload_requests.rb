module Rack
  module Cargo
    module JSONPayloadRequests
      def self.from_env(env)
        io = env[ENV_INPUT]
        return unless io

        payload = io.read
        return if payload.empty?

        json_payload = JSON.parse(payload) rescue nil
        return unless json_payload

        json_payload[REQUESTS_KEY]
      end
    end
  end
end
