# frozen_string_literal: true

module Jira
  module Pagination
    # Shared behavior for paginated collection wrappers.
    module CollectionBehavior
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

      def each_page # rubocop:disable Metrics/MethodLength
        return enum_for(:each_page) unless block_given?

        current = self
        seen_markers = {}
        loop do
          yield current
          break unless current.has_next_page?

          marker = current.pagination_progress_marker
          check_repeated_marker!(seen_markers, marker)
          seen_markers[marker] = true if marker
          current = next_page_with_progress_check(current, marker)
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

      private

      def check_repeated_marker!(seen_markers, marker)
        return unless marker
        return unless seen_markers.key?(marker)

        raise Error::Pagination, "pagination cursor repeated: #{marker.inspect}"
      end

      def next_page_with_progress_check(current, marker)
        next_page = current.next_page
        raise Error::Pagination, "pagination returned nil page" unless next_page
        return next_page unless marker
        return next_page unless next_page.pagination_progress_marker == marker

        raise Error::Pagination, "pagination did not advance from #{marker.inspect}"
      end
    end
  end
end
