require 'yaml'
require 'diffy'

class YamlSearchDiff

  def initialize
    @scalar_scanner = Psych::ScalarScanner.new(Psych::ClassLoader.new)
  end

  def run(key:, yml_1:, yml_2:)
    return "" unless yml_1.is_a?(Hash) && yml_2.is_a?(Hash)

    searched_1 = key.include?(':') ? search_dig(key, yml_1) : search(key, yml_1)
    searched_2 = key.include?(':') ? search_dig(key, yml_2) : search(key, yml_2)

    Diffy::Diff.new(
      YAML.dump(searched_1),
      YAML.dump(searched_2)
    )
  end

  private

    def search(key, yml)
      tokenized_key = @scalar_scanner.tokenize(key)
      searched = catch(:has_key) { dfs(yml, tokenized_key) }
      sort_yml(searched)
    end

    def search_dig(key, yml)
      tokenized_keys = key.split(':').map {|k| @scalar_scanner.tokenize(k) }
      first_key = tokenized_keys.first

      searched = catch(:has_key) { dfs(yml, first_key) }
      digged = searched.dig(*tokenized_keys[1..])

      sort_yml(digged)
    end

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

