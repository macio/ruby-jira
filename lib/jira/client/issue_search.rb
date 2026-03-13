# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to issue search.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-search/
    module IssueSearch
      # Returns issue suggestions for auto-completion based on a query string
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-search/#api-rest-api-3-issue-picker-get
      #
      # @param options [Hash] Query parameters (e.g. query:, currentJQL:, currentIssueKey:)
      # @return [Hash]
      def issue_picker(options = {})
        get("/issue/picker", query: options)
      end

      # Checks whether one or more issues would be returned by a JQL query
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-search/#api-rest-api-3-jql-match-post
      #
      # @param payload [Hash] Payload with JQL queries and issue IDs to match
      # @return [Hash]
      def match_issues(payload = {})
        post("/jql/match", body: payload)
      end

      # Returns an approximate count of issues matching a JQL query
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-search/#api-rest-api-3-search-approximate-count-post
      #
      # @param payload [Hash] Payload with JQL query (e.g. { jql: "project = EX" })
      # @return [Hash]
      def approximate_issue_count(payload = {})
        post("/search/approximate-count", body: payload)
      end

      # Searches for issues using JQL with reconciliation (GET)
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-search/#api-rest-api-3-search-jql-get
      #
      # @param options [Hash] Query parameters (e.g. jql:, nextPageToken:, maxResults:, fields:)
      # @return [Jira::CursorPaginatedResponse]
      def search_issues_jql(options = {})
        get("/search/jql", query: options)
      end

      # Searches for issues using JQL with reconciliation (POST)
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-search/#api-rest-api-3-search-jql-post
      #
      # @param payload [Hash] Search payload (e.g. jql:, nextPageToken:, maxResults:, fields:)
      # @return [Jira::CursorPaginatedResponse]
      def search_issues_jql_post(payload = {})
        post("/search/jql", body: payload)
      end
    end
  end
end
