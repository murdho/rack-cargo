# frozen_string_literal: true

require 'codacy-coverage'
Codacy::Reporter.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rack/cargo"

require "minitest/autorun"
require "minitest/mock"
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new
