# frozen_string_literal: true

module Jira
  class Client
    # Defines read-only methods related to workflows.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-workflows/
    module Workflows
      # Searches workflows with pagination
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-workflows/#api-rest-api-3-workflow-search-get
      #
      # @param options [Hash] Query parameters (e.g. :workflowName, :expand, :startAt, :maxResults)
      # @return [Jira::PaginatedResponse]
      def workflows(options = {})
        get("/workflow/search", query: options)
      end
    end
  end
end
