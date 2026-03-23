# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to issues via the Jira Software Cloud API.
    #
    # These methods complement the Platform API issue methods in the Issues module
    # with agile-specific fields and operations (sprint, epic, ranking, estimation).
    #
    # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-issue/
    module AgileIssues
      # Ranks issues before or after a given issue
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-issue/#api-rest-agile-1-0-issue-rank-put
      #
      # @param payload [Hash] Rank payload (issues:, rankBeforeIssue:, rankAfterIssue:, rankCustomFieldId:)
      # @return [nil]
      def rank_issues(payload = {})
        agile_put("/issue/rank", body: payload)
      end

      # Returns a single issue with agile-specific fields (sprint, epic, flagged)
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-issue/#api-rest-agile-1-0-issue-issueidorkey-get
      #
      # @param issue_id_or_key [String] The ID or key of the issue
      # @param options [Hash] Query parameters (fields:, expand:, updateHistory:)
      # @return [Hash]
      def agile_issue(issue_id_or_key, options = {})
        agile_get("/issue/#{url_encode(issue_id_or_key)}", query: options)
      end

      # Returns the estimation of the issue
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-issue/#api-rest-agile-1-0-issue-issueidorkey-estimation-get
      #
      # @param issue_id_or_key [String] The ID or key of the issue
      # @param options [Hash] Query parameters (boardId:)
      # @return [Hash]
      def issue_estimation(issue_id_or_key, options = {})
        agile_get("/issue/#{url_encode(issue_id_or_key)}/estimation", query: options)
      end

      # Updates the estimation of the issue
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-issue/#api-rest-agile-1-0-issue-issueidorkey-estimation-put
      #
      # @param issue_id_or_key [String] The ID or key of the issue
      # @param payload [Hash] Estimation payload (value:)
      # @param options [Hash] Query parameters (boardId:)
      # @return [Hash]
      def update_issue_estimation(issue_id_or_key, payload = {}, options = {})
        agile_put("/issue/#{url_encode(issue_id_or_key)}/estimation", body: payload, query: options)
      end
    end
  end
end
