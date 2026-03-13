# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to issue comments.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-comments/
    module IssueComments
      # Returns a paginated list of comments specified by a list of comment IDs
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-comments/#api-rest-api-3-comment-list-post
      #
      # @param payload [Hash] Payload with comment IDs (e.g. { ids: [1, 2, 3] })
      # @param options [Hash] Query parameters (e.g. expand:)
      # @return [Jira::PaginatedResponse]
      def comments_by_ids(payload = {}, options = {})
        post("/comment/list", body: payload, query: options)
      end

      # Returns all comments for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-comments/#api-rest-api-3-issue-issueidorkey-comment-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param options [Hash] Query parameters (e.g. startAt:, maxResults:, orderBy:, expand:)
      # @return [Jira::PaginatedResponse]
      def issue_comments(issue_id_or_key, options = {})
        get("/issue/#{url_encode(issue_id_or_key)}/comment", query: options)
      end

      # Adds a comment to an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-comments/#api-rest-api-3-issue-issueidorkey-comment-post
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param payload [Hash] Comment payload
      # @param options [Hash] Query parameters (e.g. expand:)
      # @return [Hash]
      def add_comment(issue_id_or_key, payload = {}, options = {})
        post("/issue/#{url_encode(issue_id_or_key)}/comment", body: payload, query: options)
      end

      # Returns a single comment for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-comments/#api-rest-api-3-issue-issueidorkey-comment-id-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param comment_id [Integer, String] The ID of the comment
      # @param options [Hash] Query parameters
      # @return [Hash]
      def issue_comment(issue_id_or_key, comment_id, options = {})
        get("/issue/#{url_encode(issue_id_or_key)}/comment/#{comment_id}", query: options)
      end

      # Updates a comment on an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-comments/#api-rest-api-3-issue-issueidorkey-comment-id-put
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param comment_id [Integer, String] The ID of the comment
      # @param payload [Hash] Comment payload
      # @param options [Hash] Query parameters (e.g. expand:)
      # @return [Hash]
      def update_comment(issue_id_or_key, comment_id, payload = {}, options = {})
        put("/issue/#{url_encode(issue_id_or_key)}/comment/#{comment_id}", body: payload, query: options)
      end

      # Deletes a comment from an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-comments/#api-rest-api-3-issue-issueidorkey-comment-id-delete
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param comment_id [Integer, String] The ID of the comment
      # @return [nil]
      def delete_comment(issue_id_or_key, comment_id)
        delete("/issue/#{url_encode(issue_id_or_key)}/comment/#{comment_id}")
      end
    end
  end
end
