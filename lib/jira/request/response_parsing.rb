# frozen_string_literal: true

module Jira
  class Request
    class ResponseParser
      class << self
        def parse(body)
          decoded = decode(body)
          paginated = parse_paginated(decoded)
          return paginated if paginated

          parse_non_paginated(decoded)
        end

        def decode(response)
          return {} if response.nil? || response.empty?

          JSON.parse(response, symbolize_names: true)
        rescue JSON::ParserError
          raise Error::Parsing, "The response is not a valid JSON '#{response}'"
        end

        private

        def parse_paginated(decoded)
          case pagination_model(decoded)
          when :cursor
            CursorPaginatedResponse.new(decoded)
          when :offset
            PaginatedResponse.new(decoded)
          end
        end

        def parse_non_paginated(decoded)
          return ObjectifiedHash.new(decoded) if decoded.is_a?(Hash)
          return decoded.map { |item| item.is_a?(Hash) ? ObjectifiedHash.new(item) : item } if decoded.is_a?(Array)
          return true if decoded
          return false unless decoded

          raise Error::Parsing, "Couldn't parse a response body"
        end

        def pagination_model(body)
          return nil unless body.is_a?(Hash)
          return :cursor if cursor_paginated?(body)
          return :offset if offset_paginated?(body)

          nil
        end

        # Offset-based pagination:
        # - PageBean responses: startAt/maxResults/total/isLast/nextPage + values
        # - Legacy page responses: startAt/maxResults/total + endpoint-specific items key
        def offset_paginated?(body)
          return false unless body.is_a?(Hash)
          return false if cursor_signature?(body)

          offset_values_signature?(body) || offset_generic_signature?(body)
        end

        # Cursor-based pagination:
        # - Token: nextPageToken (search/jql and similar)
        # - Cursor: nextPageCursor/cursor (plans-like)
        # - URL cursor: nextPage + lastPage without startAt (changed-worklogs style)
        # - Last page marker in token-based APIs: isLast + array without startAt
        def cursor_paginated?(body)
          return false unless body.is_a?(Hash)

          cursor_by_token?(body) ||
            cursor_by_cursor?(body) ||
            cursor_by_link?(body) ||
            cursor_last_page_without_token?(body)
        end

        def cursor_by_token?(body)
          body.key?(:nextPageToken)
        end

        def cursor_by_cursor?(body)
          body.key?(:nextPageCursor) || body.key?(:cursor)
        end

        def cursor_by_link?(body)
          body.key?(:nextPage) && body.key?(:lastPage) && !body.key?(:startAt)
        end

        def cursor_last_page_without_token?(body)
          body.key?(:isLast) && !body.key?(:startAt) && !body.key?(:values) && body.values.any?(Array)
        end

        def cursor_signature?(body)
          cursor_by_token?(body) || cursor_by_cursor?(body) || cursor_by_link?(body)
        end

        def offset_values_signature?(body)
          body.key?(:values) && (body.key?(:isLast) || body.key?(:nextPage) || body.key?(:startAt))
        end

        def offset_generic_signature?(body)
          markers_present = body.key?(:maxResults) ||
                            body.key?(:pageSize) ||
                            body.key?(:total) ||
                            body.key?(:isLast) ||
                            body.key?(:nextPage)

          body.key?(:startAt) && markers_present && body.values.any?(Array)
        end
      end
    end
  end
end
