# frozen_string_literal: true

module Jira
  class Client
    # Defines read-only methods related to screens.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-screens/
    module Screens
      # Searches screens with pagination
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-screens/#api-rest-api-3-screens-get
      #
      # @param options [Hash] Query parameters (e.g. :queryString, :id, :startAt, :maxResults)
      # @return [Jira::PaginatedResponse]
      def screens(options = {})
        get("/screens", query: options)
      end
    end
  end
end
