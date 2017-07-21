# frozen_string_literal: true

require "test_helper"
require "rack/test"

describe Rack::Cargo::Middleware do
  include Rack::Test::Methods

  def app
    @app ||= Rack::Builder.new do
      use Rack::Cargo::Middleware
      run DummyApp.new
    end
  end

  let(:batch_path) { "/batch" }

  subject { Rack::Cargo::Middleware.new(app) }

  describe "default app request" do
    specify "calling down the chain" do
      get "/"

      last_response.must_be :ok?
      last_response.body.must_equal '{"message":"Hello from GET / 0!"}'
    end
  end

  describe "batch request" do
    specify "chain execution gets sidetracked" do
      post batch_path
      last_response.body.wont_include "Hello from"
    end

    specify "requests must be in payload" do
      post batch_path

      last_response.status.must_equal 422
      last_response.body.must_include "Invalid batch request"
    end

    specify "requests must have certain structure" do
      requests = [
        {
          "name" => "first",
          "path" => "/",
          "method" => "POST",
          "body" => {}
        },
        {
          "name" => "broken",
          "path" => "/"
        }
      ]

      post batch_path, { requests: requests }.to_json, "CONTENT_TYPE" => "application/json"
      last_response.status.must_equal 422
    end

    specify "response has certain structure and content_type" do
      requests = [
        {
          "name" => "second",
          "path" => "/",
          "method" => "POST",
          "body" => { "hello" => "world" }
        }
      ]

      response = [
        {
          "name" => "second",
          "status" => 200,
          "headers" => { "Content-Type" => "application/json" },
          "body" => { "message" => "Hello from POST / 17!" }
        }
      ]

      post batch_path, { requests: requests }.to_json, "CONTENT_TYPE" => "application/json"
      last_response.content_type.must_equal "application/json"
      last_response.body.must_equal response.to_json
    end

    specify "every request gets a response" do
      requests = [
        {
          "name" => "first",
          "path" => "/rocket",
          "method" => "PATCH",
          "body" => { "test" => "drive" }
        },
        {
          "name" => "second",
          "path" => "/moon",
          "method" => "PATCH",
          "body" => { "test" => "drive" }
        }
      ]

      response = [
        {
          "name" => "first",
          "status" => 200,
          "headers" => { "Content-Type" => "application/json" },
          "body" => { "message" => "Hello from PATCH /rocket 16!" }
        },
        {
          "name" => "second",
          "status" => 200,
          "headers" => { "Content-Type" => "application/json" },
          "body" => { "message" => "Hello from PATCH /moon 16!" }
        }
      ]

      post batch_path, { requests: requests }.to_json, "CONTENT_TYPE" => "application/json"
      last_response.body.must_equal response.to_json
    end

    specify "referencing previous requests responses in batch payload by name" do
      app_builder = lambda do |status, body|
        ->(env) { [status, {}, [body.to_json]] }
      end

      @app = Rack::Builder.new do
        use Rack::Cargo::Middleware
        map "/orders/bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265/items" do
          run app_builder.call(
            201,
            {
              "uuid" => "38bc4576-3b7e-40be-a1d6-ca795fe462c8",
              "title" => "A Book"
            }
          )
        end

        map "/orders" do
          run app_builder.call(
            201,
            {
              "uuid" => "bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265",
              "address" => "Home, 12345"
            }
          )
        end

        map "/payments" do
          run app_builder.call(
            201,
            {
              "uuid" => "c4f9f261-7822-4217-80a2-06cf92934bf9",
              "orders" => [
                "bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265"
              ]
            }
          )
        end

        run app_builder[200, {}]
      end

      requests = [
        {
          "name" => "order",
          "path" => "/orders",
          "method" => "POST",
          "body" => {
            "address" => "Home, 12345"
          }
        },
        {
          "name" => "order_item",
          "path" => "/orders/{{order.uuid}}/items",
          "method" => "POST",
          "body" => {
            "title" => "A Book"
          }
        },
        {
          "name" => "payment",
          "path" => "/payments",
          "method" => "POST",
          "body" => {
            "orders" => [
              "{{order.uuid}}"
            ]
          }
        }
      ]

      response = [
        {
          "name" => "order",
          "status" => 201,
          "headers" => {},
          "body" => {
            "uuid" => "bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265",
            "address" => "Home, 12345"
          }
        },
        {
          "name" => "order_item",
          "status" => 201,
          "headers" => {},
          "body" => {
            "uuid" => "38bc4576-3b7e-40be-a1d6-ca795fe462c8",
            "title" => "A Book"
          }
        },
        {
          "name" => "payment",
          "status" => 201,
          "headers" => {},
          "body" => {
            "uuid" => "c4f9f261-7822-4217-80a2-06cf92934bf9",
            "orders" => [
              "bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265"
            ]
          }
        }
      ]

      post batch_path, { requests: requests }.to_json, "CONTENT_TYPE" => "application/json"
      last_response.body.must_equal response.to_json

      # @app = nil
    end

    specify "error response content_type is set properly" do
      post batch_path
      last_response.content_type.must_equal "application/json"
    end

    specify "detecting batch path" do
      subject.batch_request?(batch_path).must_equal true
    end

    specify "getting JSON payload from IO" do
      io = StringIO.new('{"billie": "jean"}')
      expected_result = { "billie" => "jean" }
      subject.get_json_payload(io).must_equal expected_result
    end

    specify "getting requests from JSON payload" do
      subject.get_requests("requests" => [{}]).must_equal [{}]
      subject.get_requests("random" => "").must_be_nil
      subject.get_requests(nil).must_be_nil
    end

    specify "preparing environment for a request" do
      env = { "spy" => "hello" }
      request = {
        "method" => "PATCH",
        "path" => "/red",
        "body" => { 'wine': 7 }
      }

      expected_result = {
        "spy" => "hello",
        "PATH_INFO" => "/red",
        "REQUEST_METHOD" => "PATCH",
        "rack.input" => '{"wine":7}'
      }

      # for comparing IO objects we read them
      actual_result = subject.build_request_env(request, env)
      actual_result["rack.input"] = actual_result["rack.input"].read
      actual_result.must_equal expected_result
    end

    specify "building a response for a single request" do
      args = {
        name: "abc",
        status: 200,
        headers: {},
        body: ["{}"]
      }

      expected_result = {
        "name" => "abc",
        "status" => 200,
        "headers" => {},
        "body" => {}
      }

      subject.single_response(**args).must_equal expected_result
    end

    specify "building a response for a batch" do
      responses = [{ "wanna" => "have fun?" }]
      expected_result = [200, { "Content-Type" => "application/json" }, ['[{"wanna":"have fun?"}]']]
      subject.batch_response(responses).must_equal expected_result
    end

    specify "error response" do
      status, headers, body = subject.error_response
      status.must_equal 422
      headers.must_equal "Content-Type" => "application/json"
      body.must_equal ['{"errors":"Invalid batch request"}']
    end
  end
end

class DummyApp
  def call(env)
    status = 200
    headers = { "Content-Type" => "application/json" }
    method = env["REQUEST_METHOD"]
    path = env["PATH_INFO"]
    input_length = env["rack.input"].read.length
    body = [{ message: "Hello from #{method} #{path} #{input_length}!" }.to_json]

    [status, headers, body]
  end
end
