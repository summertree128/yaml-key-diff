require 'yaml'
require 'diffy'

class YamlKeyDiff
  def self.run(key:, yml_1:, yml_2:)
    partial_1 = dfs(yml_1, key)
    partial_2 = dfs(yml_2, key)

    Diffy::Diff.new(
      YAML.dump(nested_sort_hash(partial_1)),
      YAML.dump(nested_sort_hash(partial_2))
    )
  end

  private

    def self.dfs(hash, key)
      keys = hash.keys.sort_by(&:to_s)
      keys.each do |k|
        return hash[k] if k == key
        dfs(hash[k], key) if hash[k].is_a?(Hash)
      end
      nil
    end

    def self.nested_sort_hash(hash)
      hash.each do |k, v|
        if v.is_a?(Hash)
          hash[k] = nested_sort_hash(v)
        elsif v.is_a?(Array)
          hash[k] = nested_sort_array(v)
        end
      end
      hash.sort.to_h
    end

    def self.nested_sort_array(array)
      array.each_with_index do |v, i|
        if v.is_a?(Hash)
          array[i] = nested_sort_hash(v)
        elsif v.is_a?(Array)
          array[i] = nested_sort_array(v)
        end
      end
      array.sort_by(&:to_s)
    end
end

