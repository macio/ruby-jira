# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to fields, issue types, priorities, statuses, resolutions and labels.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-fields/
    module Fields
      # Returns all system and custom fields
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-fields/#api-rest-api-3-field-get
      #
      # @param options [Hash] Query parameters
      # @return [Array<Hash>]
      def fields(options = {})
        get("/field", query: options)
      end

      # Searches fields with pagination
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-fields/#api-rest-api-3-field-search-get
      #
      # @param options [Hash] Query parameters (e.g. :query, :type, :startAt, :maxResults)
      # @return [Jira::PaginatedResponse]
      def field_search(options = {})
        get("/field/search", query: options)
      end

      # Returns all issue types
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-types/#api-rest-api-3-issuetype-get
      #
      # @return [Array<Hash>]
      def issue_types
        get("/issuetype")
      end

      # Returns all priorities
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-priorities/#api-rest-api-3-priority-get
      #
      # @return [Array<Hash>]
      def priorities
        get("/priority")
      end

      # Returns all statuses
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-workflow-statuses/#api-rest-api-3-status-get
      #
      # @return [Array<Hash>]
      def statuses
        get("/status")
      end

      # Returns all resolutions
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-resolutions/#api-rest-api-3-resolution-get
      #
      # @return [Array<Hash>]
      def resolutions
        get("/resolution")
      end

      # Returns all labels, paginated
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-labels/#api-rest-api-3-label-get
      #
      # @param options [Hash] Query parameters (e.g. :startAt, :maxResults)
      # @return [Jira::PaginatedResponse]
      def labels(options = {})
        get("/label", query: options)
      end
    end
  end
end
