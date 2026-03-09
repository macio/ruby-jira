# frozen_string_literal: true

module Jira
  class Request
    class ResponseParser
      class << self
        def parse(body) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          decoded = decode(body)
          return PaginatedResponse.new(decoded) if offset_paginated?(decoded)
          return CursorPaginatedResponse.new(decoded) if cursor_paginated?(decoded)
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
        # Requires :values and at least one offset-pagination hint.
        def offset_paginated?(body)
          body.is_a?(Hash) &&
            body.key?(:values) &&
            (body.key?(:isLast) || body.key?(:nextPage) || body.key?(:startAt))
        end

        # Cursor-based pagination: POST /search/jql, etc.
        # The token drives the next request; items live under a variable key.
        def cursor_paginated?(body)
          body.is_a?(Hash) && body.key?(:nextPageToken)
        end
      end
    end
  end
end
