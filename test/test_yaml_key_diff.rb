require 'minitest/autorun'
require 'yaml_key_diff'

class YamlKeyDiffTest < Minitest::Test
  def test_hi
    assert_equal "hello, world",
      YamlKeyDiff.hi
  end
end
