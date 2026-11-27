# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to filters.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-filters/
    module Filters
      # Returns the filters owned by or shared with the current user
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-filters/#api-rest-api-3-filter-my-get
      #
      # @param options [Hash] Query parameters (e.g. :expand, :includeFavourites)
      # @return [Array<Hash>]
      def my_filters(options = {})
        get("/filter/my", query: options)
      end

      # Returns a filter by ID
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-filters/#api-rest-api-3-filter-id-get
      #
      # @param id [Integer, String] The ID of the filter
      # @param options [Hash] Query parameters (e.g. :expand)
      # @return [Hash]
      def filter(id, options = {})
        get("/filter/#{url_encode(id)}", query: options)
      end

      # Searches filters with pagination
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-filters/#api-rest-api-3-filter-search-get
      #
      # @param options [Hash] Query parameters (e.g. :filterName, :projectId, :startAt, :maxResults)
      # @return [Jira::PaginatedResponse]
      def filter_search(options = {})
        get("/filter/search", query: options)
      end
    end
  end
end
