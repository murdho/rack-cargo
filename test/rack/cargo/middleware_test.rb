# frozen_string_literal: true

require "test_helper"
require "rack/test"

describe Rack::Cargo::Middleware do
  include Rack::Test::Methods

  let(:batch_path) { Rack::Cargo.config.batch_path }

  def app
    @app ||= fake_app(FakeAppDefault)
  end

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
          name: "first",
          path: "/",
          method: "POST",
          body: {}
        },
        {
          name: "broken",
          path: "/"
        }
      ]

      make_batch_request(requests)
      last_response.status.must_equal 422
    end


    specify "response has certain structure and content_type" do
      requests = [
        {
          name: "second",
          path: "/",
          method: "POST",
          body: { hello: "world" }
        }
      ]

      responses = [
        {
          name: "second",
          path: "/",
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { message: "Hello from POST / 17!" }
        }
      ]

      make_batch_request(requests)
      last_response.content_type.must_equal "application/json"
      last_response.body.must_equal responses.to_json
    end


    specify "every request gets a response" do
      requests = [
        {
          name: "first",
          path: "/rocket",
          method: "PATCH",
          body: { test: "drive" }
        },
        {
          name: "second",
          path: "/moon",
          method: "PATCH",
          body: { test: "drive" }
        }
      ]

      responses = [
        {
          name: "first",
          path: "/rocket",
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { message: "Hello from PATCH /rocket 16!" }
        },
        {
          name: "second",
          path: "/moon",
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { message: "Hello from PATCH /moon 16!" }
        }
      ]

      make_batch_request(requests)
      last_response.body.must_equal responses.to_json
    end


    specify "handling individual empty request body" do
      requests = [
        {
          name: "find_the_sunshine",
          path: "/sunshine",
          method: "GET",
          body: nil,
        }
      ]

      responses = [
        {
          name: "find_the_sunshine",
          path: "/sunshine",
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { message: "Hello from GET /sunshine 0!" }
        }
      ]

      make_batch_request(requests)
      last_response.body.must_equal responses.to_json
    end


    specify "handling individual empty response body" do
      @app = fake_app(FakeEmptyResponseApp)

      requests = [
        {
          name: "candy",
          path: "/candies/5w33t5un5h1n3",
          method: "DELETE",
          body: {},
        }
      ]

      responses = [
        {
          name: "candy",
          path: "/candies/5w33t5un5h1n3",
          status: 204,
          headers: { "X-Why" => "Not" },
          body: nil
        }
      ]

      make_batch_request(requests)
      last_response.body.must_equal responses.to_json
    end


    specify "referencing previous requests responses in batch payload by name" do
      @app = fake_app(FakeReferencingApp)

      requests = [
        {
          name: "order",
          path: "/orders",
          method: "POST",
          body: {
            address: "Home, 12345"
          }
        },
        {
          name: "order_item",
          path: "/orders/{{ order.uuid }}/items",
          method: "POST",
          body: {
            title: "A Book"
          }
        },
        {
          name: "payment",
          path: "/payments",
          method: "POST",
          body: {
            orders: [
              "{{ order.uuid }}"
            ]
          }
        }
      ]

      responses = [
        {
          name: "order",
          path: "/orders",
          status: 201,
          headers: {},
          body: {
            uuid: "bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265",
            address: "Home, 12345"
          }
        },
        {
          name: "order_item",
          path: "/orders/bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265/items",
          status: 201,
          headers: {},
          body: {
            uuid: "38bc4576-3b7e-40be-a1d6-ca795fe462c8",
            title: "A Book"
          }
        },
        {
          name: "payment",
          path: "/payments",
          status: 201,
          headers: {},
          body: {
            uuid: "c4f9f261-7822-4217-80a2-06cf92934bf9",
            orders: [
              "bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265"
            ]
          }
        }
      ]

      make_batch_request(requests)
      last_response.body.must_equal responses.to_json
    end


    specify "error response content_type is set properly" do
      post batch_path
      last_response.content_type.must_equal "application/json"
    end


    specify "detecting batch path" do
      subject.batch_request?(batch_path).must_equal true
    end


    specify "batch response handles different response objects according to Rack spec" do
      @app = fake_app(FakeRackResponseApp)

      requests = [
        {
          path: "/",
          method: "POST",
          body: {}
        }
      ]

      make_batch_request(requests)
      last_response.body.must_include '{"hello":"world"}'
    end

    specify "timeouting long-running single request inside a batch" do
      Rack::Cargo.configure do |config|
        config.timeout = 0.0001
      end

      @app = fake_app(FakeTimeoutApp)

      requests = [
        {
          path: "/",
          method: "POST",
          body: {}
        }
      ]

      make_batch_request(requests)

      response_json = JSON.parse(last_response.body).first
      response_json.fetch("status").must_equal 504
      response_json.fetch("headers").must_equal Hash.new
      response_json.fetch("body").must_equal Hash.new
    end


    specify "query string is handled properly" do
      @app = fake_app(FakeQueryStringApp)

      requests = [
        {
          path: "/search?q=abc",
          method: "GET",
          body: {}
        }
      ]

      expected_first_response_body = { "path" => "/search", "query" => "q=abc" }

      make_batch_request(requests)
      response_json = JSON.parse(last_response.body).first
      response_json.fetch("body").must_equal expected_first_response_body
    end
  end


  # Helpers

  def make_batch_request(requests)
    post batch_path, { requests: requests }.to_json, "CONTENT_TYPE" => "application/json"
  end

  def fake_app(app_class)
    Rack::Builder.new do
      use Rack::Cargo::Middleware
      run app_class.new
    end
  end
end

# Fake apps

class FakeBaseApp
  attr_accessor :status
  attr_accessor :headers
  attr_accessor :body

  def initialize
    self.status = 200
    self.headers = {}
    self.body = {}
  end

  def call(env)
    [status, headers, [body.to_json]]
  end
end

class FakeAppDefault < FakeBaseApp
  def call(env)
    method = env["REQUEST_METHOD"]
    path = env["PATH_INFO"]
    input_length = env["rack.input"].read.length

    self.body = { message: "Hello from #{method} #{path} #{input_length}!" }
    self.headers = { "Content-Type" => "application/json" }

    super
  end
end

class FakeReferencingApp < FakeBaseApp
  def call(env)
    req = Rack::Request.new(env)

    case req.path_info
      when "/orders" then orders_response
      when "/orders/bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265/items" then order_items_response
      when "/payments" then payments_response
    end

    super
  end

  def orders_response
    self.status = 201
    self.body = {
      uuid: "bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265",
      address: "Home, 12345"
    }
  end

  def order_items_response
    self.status = 201
    self.body = {
      uuid: "38bc4576-3b7e-40be-a1d6-ca795fe462c8",
      title: "A Book"
    }
  end

  def payments_response
    self.status = 201
    self.body = {
      uuid: "c4f9f261-7822-4217-80a2-06cf92934bf9",
      orders: [
        "bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265"
      ]
    }
  end
end

class FakeRackResponseApp < FakeBaseApp
  def call(env)
    self.body = { hello: :world }
    status, headers, body = super
    [status, headers, Rack::Response.new(body)]
  end
end

class FakeTimeoutApp < FakeBaseApp
  def call(env)
    sleep(5)
    super
  end
end

class FakeQueryStringApp < FakeBaseApp
  def call(env)
    self.body = {
      path: env["PATH_INFO"],
      query: env["QUERY_STRING"]
    }

    super
  end
end

class FakeEmptyResponseApp < FakeBaseApp
  def call(env)
    [204, {"X-Why" => "Not"}, []]
  end
end
