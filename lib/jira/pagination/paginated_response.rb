# frozen_string_literal: true

require "uri"

module Jira
  # Wrapper for Jira offset-paginated responses (values/isLast style).
  #
  # Endpoints like GET /project/search and GET /workflow/search return a body of:
  #   { values: [...], isLast: bool, total: int, nextPage: url, startAt: int, maxResults: int }
  class PaginatedResponse
    attr_accessor :client
    attr_reader :total, :max_results, :start_at, :self_url

    def initialize(body)
      @body = body
      @array = wrap_items(body.fetch(:values, []))
      @is_last = body.fetch(:isLast, false)
      @max_results = body.fetch(:maxResults, 0).to_i
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
      @is_last == false && !@next_page.to_s.empty?
    end
    alias has_next_page? next_page?

    def next_page
      return nil unless has_next_page?

      @client.get(client_relative_path(@next_page))
    end

    def client_relative_path(link)
      client_endpoint_path = @client.api_request_path
      URI.parse(link).request_uri.sub(client_endpoint_path, "")
    end

    private

    def wrap_items(items)
      items.map { |item| item.is_a?(Hash) ? ObjectifiedHash.new(item) : item }
    end
  end
end
