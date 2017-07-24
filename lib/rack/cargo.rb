# frozen_string_literal: true

require "json"
require "securerandom"

module Rack
  module Cargo
    BATCH_PATH = "/batch"
    REQUESTS_KEY = "requests"

    ENV_PATH = "PATH_INFO"
    ENV_INPUT = "rack.input"
    ENV_METHOD = "REQUEST_METHOD"

    REQUEST_NAME = "name"
    REQUEST_PATH = "path"
    REQUEST_METHOD = "method"
    REQUEST_BODY = "body"

    RESPONSE_NAME = "name"
    RESPONSE_STATUS = "status"
    RESPONSE_HEADERS = "headers"
    RESPONSE_BODY = "body"

    autoload :Version, "rack/cargo/version"
    autoload :Middleware, "rack/cargo/middleware"

    autoload :BatchProcessor, "rack/cargo/batch_processor"

    autoload :JSONPayloadRequests, "rack/cargo/json_payload_requests"
    autoload :RequestValidator, "rack/cargo/request_validator"
    autoload :ReferenceResolver, "rack/cargo/reference_resolver"
    autoload :RequestEnvBuilder, "rack/cargo/request_env_builder"
    autoload :RequestExecutor, "rack/cargo/request_executor"
    autoload :ResponseBuilder, "rack/cargo/response_builder"

    autoload :BatchResponse, "rack/cargo/batch_response"
  end
end
