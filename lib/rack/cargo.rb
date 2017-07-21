# frozen_string_literal: true

require "json"

module Rack
  module Cargo
    autoload :Version, "rack/cargo/version"
    autoload :Responses, "rack/cargo/responses"
    autoload :Middleware, "rack/cargo/middleware"
    autoload :RequestProcessing, "rack/cargo/request_processing"
  end
end
