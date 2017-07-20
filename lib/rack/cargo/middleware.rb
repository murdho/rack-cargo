module Rack
  module Cargo
    class Middleware
      attr_accessor :app

      def initialize(app)
        self.app = app
      end

      def call(env)
        if batch_request?(env['PATH_INFO'])
          process_batch_request(env)
        else
          @app.call(env)
        end
      end

      def process_batch_request(env)
        requests = get_requests(env['rack.input'])
        if requests
          responses = []
          requests.each do |request|
            responses << process_request(request, env)
          end
          batch_response(responses)
        else
          error_response
        end
      end

      def process_request(request, env)
        request_env = build_request_env(request, env)

        status, headers, body = @app.call(request_env)
        body.close if body.respond_to?(:close)

        single_response(
          name: request['name'],
          status: status,
          headers: headers,
          body: body
        )
      end

      def batch_request?(path)
        path == '/batch'
      end

      def get_json_payload(io)
        payload = io.read
        return if payload.empty?

        JSON.parse(payload) rescue nil
      end

      def get_requests(io)
        json_payload = get_json_payload(io)
        return unless json_payload && json_payload.key?('requests')
        json_payload['requests']
      end

      def build_request_env(request, env)
        request_env = env.dup
        request_env['PATH_INFO'] = request['path']
        request_env['REQUEST_METHOD'] = request['method']
        request_env['rack.input'] = StringIO.new(request['body'].to_json)
        request_env
      end

      def single_response(**args)
        {
          'name' => args.fetch(:name),
          'status' => args.fetch(:status),
          'headers' => args.fetch(:headers),
          'body' => JSON.parse(args.fetch(:body).join)
        }
      end

      def batch_response(responses)
        [200, { 'Content-Type' => 'application/json' }, [responses.to_json]]
      end

      def error_response
        [422, { 'Content-Type' => 'application/json' }, [{ errors: 'missing key: requests' }.to_json]]
      end
    end
  end
end
