require 'minitest/autorun'
require 'yaml_search_diff'

class YamlSearchDiffTest < Minitest::Test
  def test_run
    str_1 = <<~YAML_EOT
      key1:
        nested_key1: aaa
      key2:
        nested_key2: bbb
      key3:
        nested_key3:
          nested_nested_key:
            - AAAAA
            - BBBBB
            - CCCCC
          nested_nested_key2:
            - nested_nested_nested_key: XXXX
            - nested_nested_nested_key2: YYYY
          true: yes
          false: no
      YAML_EOT

    str_2 = <<~YAML_EOT
      key1:
        nested_key1: aaa
      key2:
        nested_key2: ccc
      key3:
        nested_key3:
          nested_nested_key:
            - CCCCC
            - DDDDD
            - EEEEE
            - FFFFF
      YAML_EOT

    yml_1 = YAML.load(str_1)
    yml_2 = YAML.load(str_2)

    assert_equal(
      "",
      YamlSearchDiff.run(key: 'non-existence-key', yml_1: yml_1, yml_2: yml_2).to_s
    )

    assert_equal(
      "",
      YamlSearchDiff.run(key: 'key1', yml_1: yml_1, yml_2: yml_2).to_s
    )

    expected_diff_key1 = <<~EXPECTED_DIFF
     ---
    -nested_key2: bbb
    +nested_key2: ccc
    EXPECTED_DIFF

    assert_equal(
      expected_diff_key1,
      YamlSearchDiff.run(key: 'key2', yml_1: yml_1, yml_2: yml_2).to_s
    )


    expected_diff_nested_key3 = <<~EXPECTED_DIFF
     ---
    -false: false
     nested_nested_key:
    -- AAAAA
    -- BBBBB
     - CCCCC
    -nested_nested_key2:
    -- nested_nested_nested_key: XXXX
    -- nested_nested_nested_key2: YYYY
    -true: true
    +- DDDDD
    +- EEEEE
    +- FFFFF
    EXPECTED_DIFF

    assert_equal(
      expected_diff_nested_key3,
      YamlSearchDiff.run(key: 'nested_key3', yml_1: yml_1, yml_2: yml_2).to_s
    )
  end

  def test_empty_file
    str_1 = ''
    str_2 = ''
    yml_1 = YAML.load(str_1)
    yml_2 = YAML.load(str_2)

    assert_equal(
      "",
      YamlSearchDiff.run(key: 'key1', yml_1: yml_1, yml_2: yml_2)
    ).to_s
  end

  def test_nested_array
    str_1 = <<~YAML_EOT
    key1:
      - AAA
      - BBB
      - [ aaa, bbb, ccc]
    YAML_EOT

    str_2 = <<~YAML_EOT
    key1:
      - [ ddd, eee, [ fff, ggg ]]
      - AAA
      - [ hhh ]
      - [ bbb, ccc ]
    YAML_EOT

    yml_1 = YAML.load(str_1)
    yml_2 = YAML.load(str_2)

    expected_diff = <<~EXPECTED_DIFF
     ---
     - AAA
    -- BBB
    -- - aaa
    -  - bbb
    +- - bbb
       - ccc
    +- - hhh
    +- - - fff
    +    - ggg
    +  - ddd
    +  - eee
    EXPECTED_DIFF

    assert_equal(
      expected_diff,
      YamlSearchDiff.run(key: 'key1', yml_1: yml_1, yml_2: yml_2).to_s
    )
  end

  def test_dig
    str_1 = <<~YAML_EOT
      key1:
        nested_key1:
          nested_nested_key1:
            - AAA
            - BBB
      key2:
        nested_key1:
          nested_nested_key1:
            - CCC
    YAML_EOT

    str_2 = <<~YAML_EOT
      key1:
        nested_key1:
          nested_nested_key1:
            - DDD
            - AAA
          nested_nested_key2:
            - bbb
      key2:
        nested_key1:
          nested_nested_key1: CCC
    YAML_EOT

    yml_1 = YAML.load(str_1)
    yml_2 = YAML.load(str_2)

    expected_diff_1 = <<~DIFF
     ---
     - AAA
    -- BBB
    +- DDD
    DIFF

    assert_equal(
      expected_diff_1,
      YamlSearchDiff.run(key: 'key1:nested_key1:nested_nested_key1', yml_1: yml_1, yml_2: yml_2).to_s
    )

    expected_diff_2 = <<~DIFF
     ---
    +- bbb
    DIFF

    assert_equal(
      expected_diff_2,
      YamlSearchDiff.run(key: 'key1:nested_key1:nested_nested_key2', yml_1: yml_1, yml_2: yml_2)
.to_s
    )

    expected_diff_3 = <<~DIFF
    ----
    -- CCC
    +--- CCC
    DIFF

    assert_equal(
      expected_diff_3,
      YamlSearchDiff.run(key: 'key2:nested_key1:nested_nested_key1', yml_1: yml_1, yml_2: yml_2).to_s
    )

    expected_diff_4 = ''

    assert_equal(
      expected_diff_4,
      YamlSearchDiff.run(key: 'key1:non-existence_key', yml_1: yml_1, yml_2: yml_2).to_s
    )
  end
end
