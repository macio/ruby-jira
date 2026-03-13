# frozen_string_literal: true

require "uri"

module Jira
  # Wrapper for Jira cursor-paginated responses.
  #
  # Endpoints like POST /search/jql return a body of:
  #   { nextPageToken: "token", total: int, <items_key>: [...] }
  # Some Jira APIs use alternative cursor fields:
  #   { nextPageCursor: "cursor", ... } or { cursor: "...", nextPageCursor: "...", last: false, ... }
  # Other APIs use URL-based cursor fields:
  #   { nextPage: "https://...", lastPage: false, ... }
  #
  # The items array key varies by endpoint (e.g. "issues", "worklogs").
  # This class detects it automatically as the first non-metadata Array value.
  #
  # Pagination is driven by a +next_page_fetcher+ proc set by the Request layer,
  # which re-issues the original request with +nextPageToken+ injected.
  class CursorPaginatedResponse
    include Logging
    include Pagination::CollectionBehavior

    METADATA_KEYS = %i[
      nextPageToken nextPageCursor cursor nextPage total self isLast last lastPage expand warningMessages maxResults
      startAt size
    ].freeze

    attr_accessor :client, :next_page_fetcher
    attr_reader :next_page_token, :next_page_cursor, :next_page_url, :total

    def initialize(body) # rubocop:disable Metrics/AbcSize
      @next_page_token = body[:nextPageToken]
      @next_page_cursor = body[:nextPageCursor] || body[:cursor]
      @next_page_url = body[:nextPage]
      @is_last = body[:isLast]
      @last = body[:last]
      @last_page = body[:lastPage]
      @total = body.fetch(:total, 0).to_i
      items_key, items = detect_items_array(body)
      log "CursorPaginatedResponse: items_key=#{items_key.inspect} count=#{items.length}"
      @array = wrap_items(items)
    end

    def next_page?
      return false if @is_last == true || @last == true || @last_page == true

      !next_page_locator.to_s.empty?
    end
    alias has_next_page? next_page?

    def next_page
      return nil unless has_next_page?
      return next_page_by_link unless @next_page_url.to_s.empty?
      raise Error::MissingCredentials, "next_page_fetcher not set on CursorPaginatedResponse" unless @next_page_fetcher

      @next_page_fetcher.call(next_page_locator)
    end

    def cursor_parameter_key
      return :nextPageToken unless @next_page_token.to_s.empty?
      return :cursor unless @next_page_cursor.to_s.empty?

      nil
    end

    def fetcher_based_pagination?
      @next_page_url.to_s.empty?
    end

    def pagination_progress_marker
      next_page_locator
    end

    private

    def next_page_locator
      return @next_page_token unless @next_page_token.to_s.empty?
      return @next_page_cursor unless @next_page_cursor.to_s.empty?
      return @next_page_url unless @next_page_url.to_s.empty?

      nil
    end

    def next_page_by_link
      raise Error::MissingCredentials, "client not set on CursorPaginatedResponse" unless @client

      @client.get(client_relative_path(@next_page_url))
    end

    def client_relative_path(link)
      client_endpoint_path = @client.api_request_path
      URI.parse(link).request_uri.sub(client_endpoint_path, "")
    end

    def detect_items_array(body)
      body.each do |key, value|
        next if METADATA_KEYS.include?(key)
        return [key, value] if value.is_a?(Array)
      end
      [nil, []]
    end

    def wrap_items(items)
      items.map { |item| item.is_a?(Hash) ? ObjectifiedHash.new(item) : item }
    end
  end
end
