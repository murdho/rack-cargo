# frozen_string_literal: true

require "test_helper"

module Rack
  class CargoTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::Rack::Cargo::VERSION
    end

    def test_configuration
      Rack::Cargo.configure do |config|
        config.batch_path = '/hello'
      end

      assert_equal '/hello', Rack::Cargo.config.batch_path
    end
  end
end
