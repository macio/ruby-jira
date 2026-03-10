# frozen_string_literal: true

require "uri"

module Jira
  # Wrapper for Jira offset-paginated responses.
  #
  # Supports two formats:
  # - Classic: { values: [...], isLast: bool, nextPage: url, startAt: int, maxResults: int, total: int }
  #   (GET /project/search, GET /issue/{key}/changelog, POST /comment/list)
  # - Legacy: { <items_key>: [...], startAt: int, maxResults: int, total: int }
  #   (GET /search, GET /issue/{key}/comment)
  #
  # For legacy format, items key is auto-detected (first non-metadata Array value).
  # When nextPage URL is absent, a next_page_fetcher proc set by the Request layer
  # drives pagination by incrementing startAt.
  class PaginatedResponse
    include Logging

    METADATA_KEYS = %i[
      isLast maxResults nextPage self startAt total pageSize nextPageToken expand warningMessages
    ].freeze

    attr_accessor :client, :next_page_fetcher
    attr_reader :total, :max_results, :start_at, :self_url

    def initialize(body) # rubocop:disable Metrics/AbcSize
      @body = body
      items_key, items = detect_items(body)
      log "PaginatedResponse: items_key=#{items_key.inspect} count=#{items.length}"
      @array = wrap_items(items)
      @is_last = body.key?(:isLast) ? body[:isLast] : (@array.length + body.fetch(:startAt, 0) >= body.fetch(:total, 0))
      @max_results = (body[:maxResults] || body[:pageSize] || items.length).to_i
      @next_page = body.fetch(:nextPage, "")
      @self_url = body.fetch(:self, "")
      @start_at = body.fetch(:startAt, 0).to_i
      @total = body.fetch(:total, 0).to_i
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

    def last_page?
      @is_last == true
    end
    alias has_last_page? last_page?

    def first_page?
      @start_at.zero?
    end
    alias has_first_page? first_page?

    def next_page?
      !last_page? && (!@next_page.to_s.empty? || !@next_page_fetcher.nil?)
    end
    alias has_next_page? next_page?

    def next_page
      return nil unless next_page?
      return @client.get(client_relative_path(@next_page)) unless @next_page.to_s.empty?

      @next_page_fetcher.call(@start_at + @max_results)
    end

    def client_relative_path(link)
      client_endpoint_path = @client.api_request_path
      URI.parse(link).request_uri.sub(client_endpoint_path, "")
    end

    private

    def detect_items(body)
      return [:values, body[:values]] if body.key?(:values)

      body.each { |k, v| return [k, v] if !METADATA_KEYS.include?(k) && v.is_a?(Array) }
      [nil, []]
    end

    def wrap_items(items)
      items.map { |item| item.is_a?(Hash) ? ObjectifiedHash.new(item) : item }
    end
  end
end
