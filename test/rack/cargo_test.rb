# frozen_string_literal: true

require "test_helper"

module Rack
  class CargoTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::Rack::Cargo::VERSION
    end
  end
end
