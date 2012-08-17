require 'test_helper'

class RailsUpgraderTest < ActiveSupport::TestCase

  def open_model(model)
    sample = File.open("#{Dir.pwd}/test/fixtures/#{model}.rb").readlines
    output = File.open("#{Dir.pwd}/test/fixtures/#{model}_parsed.rb").read
    return [sample, output]
  end
  
  def test_converts_validators
    sample, output = open_model('model')

    assert_equal(Dg::RailsUpgrader.new(sample).convert_validators, output)
  end
end
