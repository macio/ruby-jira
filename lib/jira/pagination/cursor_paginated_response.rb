# frozen_string_literal: true

module Jira
  # Wrapper for Jira cursor-paginated responses (nextPageToken style).
  #
  # Endpoints like POST /search/jql return a body of:
  #   { nextPageToken: "token", total: int, <items_key>: [...] }
  #
  # The items array key varies by endpoint (e.g. "issues", "worklogs").
  # This class detects it automatically as the first non-metadata Array value.
  #
  # Pagination is driven by a +next_page_fetcher+ proc set by the Request layer,
  # which re-issues the original request with +nextPageToken+ injected.
  class CursorPaginatedResponse
    METADATA_KEYS = %i[nextPageToken total self].freeze

    attr_accessor :client, :next_page_fetcher
    attr_reader :next_page_token, :total

    def initialize(body)
      @body = body
      @next_page_token = body[:nextPageToken]
      @total = body.fetch(:total, 0).to_i
      @array = wrap_items(detect_items_array(body))
    end

    def inspect
      @array.inspect
    end

    def method_missing(name, *, &)
      return @array.send(name, *, &) if @array.respond_to?(name)

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      super || @array.respond_to?(method_name, include_private)
    end

    def each_page
      current = self
      yield current
      while current.has_next_page?
        current = current.next_page
        yield current
      end
    end

    def lazy_paginate
      to_enum(:each_page).lazy.flat_map(&:to_ary)
    end

    def auto_paginate(&block)
      return lazy_paginate.to_a unless block

      lazy_paginate.each(&block)
    end

    def paginate_with_limit(limit, &block)
      return lazy_paginate.take(limit).to_a unless block

      lazy_paginate.take(limit).each(&block)
    end

    def next_page?
      !@next_page_token.to_s.empty?
    end
    alias has_next_page? next_page?

    def next_page
      return nil unless has_next_page?
      raise Error::MissingCredentials, "next_page_fetcher not set on CursorPaginatedResponse" unless @next_page_fetcher

      @next_page_fetcher.call(@next_page_token)
    end

    private

    def detect_items_array(body)
      body.each do |key, value|
        next if METADATA_KEYS.include?(key)
        return value if value.is_a?(Array)
      end
      []
    end

    def wrap_items(items)
      items.map { |item| item.is_a?(Hash) ? ObjectifiedHash.new(item) : item }
    end
  end
end
