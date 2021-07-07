require 'minitest/autorun'
require 'yaml_search_diff'

class YamlSearchDiffTest < Minitest::Test
  def test_run
    str_1 = <<~YAML_EOT
    key1:
      nested_key1: aaa
    key2:
      nested_key2: bbb
    YAML_EOT

    str_2 = <<~YAML_EOT
    key1:
      nested_key1: aaa
    key2:
      nested_key2: ccc
    YAML_EOT

    yml_1 = YAML.load(str_1)
    yml_2 = YAML.load(str_2)

    assert_equal "",
      YamlSearchDiff.run(key: 'key1', yml_1: yml_1, yml_2: yml_2).to_s

    expected_diff = <<~EXPECTED_DIFF
     ---
    -nested_key2: bbb
    +nested_key2: ccc
    EXPECTED_DIFF

    assert_equal expected_diff,
      YamlSearchDiff.run(key: 'key2', yml_1: yml_1, yml_2: yml_2).to_s
  end

  def test_empty_file
    str_1 = ''
    str_2 = ''
    yml_1 = YAML.load(str_1)
    yml_2 = YAML.load(str_2)

    assert_equal "",
      YamlSearchDiff.run(key: 'key1', yml_1: yml_1, yml_2: yml_2).to_s
  end
end
