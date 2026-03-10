# frozen_string_literal: true

module Jira
  class Request
    class ResponseParser
      class << self
        def parse(body) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          decoded = decode(body)
          return CursorPaginatedResponse.new(decoded) if cursor_paginated?(decoded)
          return PaginatedResponse.new(decoded) if offset_paginated?(decoded)
          return ObjectifiedHash.new(decoded) if decoded.is_a?(Hash)
          return decoded.map { |item| item.is_a?(Hash) ? ObjectifiedHash.new(item) : item } if decoded.is_a?(Array)
          return true if decoded
          return false unless decoded

          raise Error::Parsing, "Couldn't parse a response body"
        end

        def decode(response)
          return {} if response.nil? || response.empty?

          JSON.parse(response, symbolize_names: true)
        rescue JSON::ParserError
          raise Error::Parsing, "The response is not a valid JSON '#{response}'"
        end

        private

        # Offset-based pagination: GET /project/search, GET /workflow/search, etc.
        # Classic format: :values array + pagination hints.
        # Legacy format: :startAt without :isLast or :nextPageToken (e.g. GET /search, GET /issue/{key}/comment).
        def offset_paginated?(body) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          return false unless body.is_a?(Hash)
          return false if body.key?(:nextPageToken)

          return true if body.key?(:values) && (body.key?(:isLast) || body.key?(:nextPage) || body.key?(:startAt))

          body.key?(:startAt) && !body.key?(:isLast) && body.values.any?(Array)
        end

        # Cursor-based pagination: POST /search/jql, GET /search/jql, etc.
        # Matches when :nextPageToken is present (any page), or when :isLast is present
        # without :values (last page of cursor response has no token).
        def cursor_paginated?(body)
          body.is_a?(Hash) && (
            body.key?(:nextPageToken) ||
            (body.key?(:isLast) && !body.key?(:values) && body.values.any?(Array))
          )
        end
      end
    end
  end
end
