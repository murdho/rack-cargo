# frozen_string_literal: true

require "json"

module Rack
  module Cargo
    autoload :Version, "rack/cargo/version"
    # autoload :Responses, "rack/cargo/responses"
    autoload :Middleware, "rack/cargo/middleware"
    # autoload :RequestProcessing, "rack/cargo/request_processing"
    # autoload :RequestReferencing, "rack/cargo/request_referencing"
    autoload :ReferenceResolver, "rack/cargo/reference_resolver"
    autoload :RequestEnvBuilder, "rack/cargo/request_env_builder"
    autoload :RequestExecutor, "rack/cargo/request_executor"
    autoload :ResponseBuilder, "rack/cargo/response_builder"
    autoload :JSONPayloadRequests, "rack/cargo/json_payload_requests"
    autoload :RequestValidator, "rack/cargo/request_validator"
    autoload :BatchProcessor, "rack/cargo/batch_processor"

    BATCH_PATH = "/batch"
    REQUESTS_KEY = "requests"

    ENV_PATH = "PATH_INFO"
    ENV_INPUT = "rack.input"
    ENV_METHOD = "REQUEST_METHOD"

    REQUEST_NAME = "name"
    REQUEST_PATH = "path"
    REQUEST_METHOD = "method"
    REQUEST_BODY = "body"
  end
end
