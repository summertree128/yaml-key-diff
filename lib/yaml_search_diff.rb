require 'yaml'
require 'diffy'

class YamlSearchDiff
  class << self
    def run(key:, yml_1:, yml_2:)
      return "" unless yml_1.is_a?(Hash) && yml_2.is_a?(Hash)

      searched_1 = catch(:has_key) { dfs(yml_1, key) }
      searched_2 = catch(:has_key) { dfs(yml_2, key) }

      sorted_1 = sort_yml(searched_1)
      sorted_2 = sort_yml(searched_2)

      Diffy::Diff.new(
        YAML.dump(sorted_1),
        YAML.dump(sorted_2)
      )
    end

    private

      def dfs(hash, key)
        keys = hash.keys.sort_by(&:to_s)
        keys.each do |k|
          throw :has_key, hash[k] if k == key
          dfs(hash[k], key) if hash[k].is_a?(Hash)
        end
        {}
      end

      def sort_yml(yml)
        if yml.is_a?(Hash)
          nested_sort_hash(yml)
        elsif yml.is_a?(Array)
          nested_sort_array(yml)
        else
          yml
        end
      end

      def nested_sort_hash(hash)
        hash.each do |k, v|
          if v.is_a?(Hash)
            hash[k] = nested_sort_hash(v)
          elsif v.is_a?(Array)
            hash[k] = nested_sort_array(v)
          end
        end
        hash.sort_by { |k, v| k.to_s }.to_h
      end

      def nested_sort_array(array)
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
end

