# frozen_string_literal: true

module Jira
  # Wraps a Hash to allow dot-notation access alongside bracket access.
  #
  # @example
  #   issue = Jira::ObjectifiedHash.new({ key: "TEST-1", fields: { summary: "Bug" } })
  #   issue.key          # => "TEST-1"
  #   issue[:key]        # => "TEST-1"
  #   issue.fields       # => <Jira::ObjectifiedHash ...>
  #   issue.fields.summary  # => "Bug"
  #   issue.to_h         # => { key: "TEST-1", ... }
  class ObjectifiedHash
    def initialize(hash)
      @hash = hash
      @data = hash.each_with_object({}) do |(key, value), data|
        sym_key = key.to_sym
        value = self.class.new(value) if value.is_a?(Hash)
        value = value.map { |v| v.is_a?(Hash) ? self.class.new(v) : v } if value.is_a?(Array)
        data[sym_key] = value
      end
    end

    # @return [Hash] The original hash with original key types.
    def to_hash
      @hash
    end
    alias to_h to_hash

    def inspect
      "#<#{self.class}:#{object_id} {hash: #{@hash.inspect}}>"
    end

    # Supports both symbol and string key access.
    def [](key)
      @data[key.to_sym]
    end

    # Supports nested key traversal, mirroring Hash#dig.
    def dig(key, *rest)
      value = self[key]
      return value if rest.empty?
      return nil unless value.respond_to?(:dig)

      value.dig(*rest)
    end

    def ==(other)
      return @hash == other.to_h if other.is_a?(self.class)

      @hash == other
    end

    private

    def method_missing(method_name, *, &)
      return @data[method_name] if @data.key?(method_name)

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      @data.key?(method_name) || super
    end
  end
end
