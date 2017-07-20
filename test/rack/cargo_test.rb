require "test_helper"

class Rack::CargoTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rack::Cargo::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
