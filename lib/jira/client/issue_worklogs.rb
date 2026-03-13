# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to issue worklogs.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/
    module IssueWorklogs
      # Returns worklogs for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/#api-rest-api-3-issue-issueidorkey-worklog-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param options [Hash] Query parameters
      # @return [Jira::PaginatedResponse]
      def issue_worklogs(issue_id_or_key, options = {})
        get("/issue/#{url_encode(issue_id_or_key)}/worklog", query: options)
      end

      # Adds a worklog to an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/#api-rest-api-3-issue-issueidorkey-worklog-post
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param payload [Hash] Worklog payload
      # @param options [Hash] Query parameters
      # @return [Hash]
      def add_worklog(issue_id_or_key, payload = {}, options = {})
        post("/issue/#{url_encode(issue_id_or_key)}/worklog", body: payload, query: options)
      end

      # Bulk deletes worklogs from an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/#api-rest-api-3-issue-issueidorkey-worklog-delete
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param payload [Hash] Worklog IDs payload
      # @return [nil]
      def bulk_delete_worklogs(issue_id_or_key, payload = {})
        delete("/issue/#{url_encode(issue_id_or_key)}/worklog", body: payload)
      end

      # Bulk moves worklogs from an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/#api-rest-api-3-issue-issueidorkey-worklog-move-post
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param payload [Hash] Move worklogs payload
      # @return [nil]
      def bulk_move_worklogs(issue_id_or_key, payload = {})
        post("/issue/#{url_encode(issue_id_or_key)}/worklog/move", body: payload)
      end

      # Returns a single worklog for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/#api-rest-api-3-issue-issueidorkey-worklog-id-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param worklog_id [Integer, String] The ID of the worklog
      # @param options [Hash] Query parameters
      # @return [Hash]
      def worklog(issue_id_or_key, worklog_id, options = {})
        get("/issue/#{url_encode(issue_id_or_key)}/worklog/#{worklog_id}", query: options)
      end

      # Updates a worklog on an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/#api-rest-api-3-issue-issueidorkey-worklog-id-put
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param worklog_id [Integer, String] The ID of the worklog
      # @param payload [Hash] Worklog payload
      # @param options [Hash] Query parameters
      # @return [Hash]
      def update_worklog(issue_id_or_key, worklog_id, payload = {}, options = {})
        put("/issue/#{url_encode(issue_id_or_key)}/worklog/#{worklog_id}", body: payload, query: options)
      end

      # Deletes a worklog from an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/#api-rest-api-3-issue-issueidorkey-worklog-id-delete
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param worklog_id [Integer, String] The ID of the worklog
      # @param options [Hash] Query parameters
      # @return [nil]
      def delete_worklog(issue_id_or_key, worklog_id, options = {})
        delete("/issue/#{url_encode(issue_id_or_key)}/worklog/#{worklog_id}", query: options)
      end

      # Returns IDs of worklogs deleted since a given time
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/#api-rest-api-3-worklog-deleted-get
      #
      # @param options [Hash] Query parameters (e.g. since:)
      # @return [Jira::CursorPaginatedResponse]
      def deleted_worklog_ids(options = {})
        get("/worklog/deleted", query: options)
      end

      # Returns worklogs for a list of IDs
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/#api-rest-api-3-worklog-list-post
      #
      # @param payload [Hash] Worklog IDs payload
      # @param options [Hash] Query parameters
      # @return [Array<Hash>]
      def worklogs_for_ids(payload = {}, options = {})
        post("/worklog/list", body: payload, query: options)
      end

      # Returns IDs of worklogs updated since a given time
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-worklogs/#api-rest-api-3-worklog-updated-get
      #
      # @param options [Hash] Query parameters (e.g. since:)
      # @return [Jira::CursorPaginatedResponse]
      def updated_worklog_ids(options = {})
        get("/worklog/updated", query: options)
      end
    end
  end
end
