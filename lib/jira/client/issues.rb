# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to issues.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/
    module Issues
      # Creates a new issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-post
      #
      # @param payload [Hash] Issue payload
      # @return [Hash]
      def create_issue(payload = {})
        post("/issue", body: payload)
      end

      # Creates multiple issues in a single request
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-bulk-post
      #
      # @param payload [Hash] Bulk issue creation payload
      # @return [Hash]
      def bulk_create_issues(payload = {})
        post("/issue/bulk", body: payload)
      end

      # Gets a single issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param options [Hash] Query parameters
      # @return [Hash]
      def issue(issue_id_or_key, options = {})
        get("/issue/#{url_encode(issue_id_or_key)}", query: options)
      end

      # Updates an existing issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-put
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param payload [Hash] Issue payload
      # @param options [Hash] Query parameters
      # @return [Hash]
      def edit_issue(issue_id_or_key, payload = {}, options = {})
        put("/issue/#{url_encode(issue_id_or_key)}", body: payload, query: options)
      end

      # Deletes an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-delete
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param options [Hash] Query parameters (e.g. deleteSubtasks)
      # @return [nil]
      def delete_issue(issue_id_or_key, options = {})
        delete("/issue/#{url_encode(issue_id_or_key)}", query: options)
      end

      # Assigns an issue to a user
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-assignee-put
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param payload [Hash] Assignee payload (e.g. { accountId: "..." })
      # @return [nil]
      def assign_issue(issue_id_or_key, payload = {})
        put("/issue/#{url_encode(issue_id_or_key)}/assignee", body: payload)
      end

      # Returns a list of transitions for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-transitions-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param options [Hash] Query parameters
      # @return [Hash]
      def issue_transitions(issue_id_or_key, options = {})
        get("/issue/#{url_encode(issue_id_or_key)}/transitions", query: options)
      end

      # Performs a transition on an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-transitions-post
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param payload [Hash] Transition payload
      # @return [nil]
      def transition_issue(issue_id_or_key, payload = {})
        post("/issue/#{url_encode(issue_id_or_key)}/transitions", body: payload)
      end

      # Returns paginated changelog for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-changelog-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param options [Hash] Query parameters
      # @return [Jira::PaginatedResponse]
      def issue_changelog(issue_id_or_key, options = {})
        get("/issue/#{url_encode(issue_id_or_key)}/changelog", query: options)
      end

      # Returns the watchers for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-watchers-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @return [Hash]
      def issue_watchers(issue_id_or_key)
        get("/issue/#{url_encode(issue_id_or_key)}/watchers")
      end

      # Adds a watcher to an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-watchers-post
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param account_id [String] The account ID of the user to watch the issue
      # @return [nil]
      def add_watcher(issue_id_or_key, account_id)
        post("/issue/#{url_encode(issue_id_or_key)}/watchers", body: account_id)
      end

      # Removes a watcher from an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-watchers-delete
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param account_id [String] The account ID of the user to remove
      # @return [nil]
      def remove_watcher(issue_id_or_key, account_id:)
        delete("/issue/#{url_encode(issue_id_or_key)}/watchers", query: { accountId: account_id })
      end

      # Returns vote information for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-votes-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @return [Hash]
      def issue_votes(issue_id_or_key)
        get("/issue/#{url_encode(issue_id_or_key)}/votes")
      end

      # Adds a vote to an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-votes-post
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @return [nil]
      def add_vote(issue_id_or_key)
        post("/issue/#{url_encode(issue_id_or_key)}/votes")
      end

      # Removes a vote from an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-votes-delete
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @return [nil]
      def remove_vote(issue_id_or_key)
        delete("/issue/#{url_encode(issue_id_or_key)}/votes")
      end

      # Returns worklogs for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-worklog-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param options [Hash] Query parameters
      # @return [Hash]
      def issue_worklogs(issue_id_or_key, options = {})
        get("/issue/#{url_encode(issue_id_or_key)}/worklog", query: options)
      end

      # Adds a worklog to an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-worklog-post
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param payload [Hash] Worklog payload
      # @param options [Hash] Query parameters
      # @return [Hash]
      def add_worklog(issue_id_or_key, payload = {}, options = {})
        post("/issue/#{url_encode(issue_id_or_key)}/worklog", body: payload, query: options)
      end

      # Returns a single worklog for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-worklog-id-get
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
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-worklog-id-put
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
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-worklog-id-delete
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param worklog_id [Integer, String] The ID of the worklog
      # @param options [Hash] Query parameters
      # @return [nil]
      def delete_worklog(issue_id_or_key, worklog_id, options = {})
        delete("/issue/#{url_encode(issue_id_or_key)}/worklog/#{worklog_id}", query: options)
      end

      # Returns remote links for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-remotelink-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param options [Hash] Query parameters
      # @return [Array<Hash>]
      def issue_remote_links(issue_id_or_key, options = {})
        get("/issue/#{url_encode(issue_id_or_key)}/remotelink", query: options)
      end

      # Creates or updates a remote link for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-remotelink-post
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param payload [Hash] Remote link payload
      # @return [Hash]
      def create_or_update_remote_link(issue_id_or_key, payload = {})
        post("/issue/#{url_encode(issue_id_or_key)}/remotelink", body: payload)
      end

      # Returns a single remote link for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-remotelink-linkid-get
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param link_id [Integer, String] The ID of the remote link
      # @return [Hash]
      def remote_link(issue_id_or_key, link_id)
        get("/issue/#{url_encode(issue_id_or_key)}/remotelink/#{link_id}")
      end

      # Updates a remote link for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-remotelink-linkid-put
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param link_id [Integer, String] The ID of the remote link
      # @param payload [Hash] Remote link payload
      # @return [nil]
      def update_remote_link(issue_id_or_key, link_id, payload = {})
        put("/issue/#{url_encode(issue_id_or_key)}/remotelink/#{link_id}", body: payload)
      end

      # Deletes a remote link from an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-remotelink-linkid-delete
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param link_id [Integer, String] The ID of the remote link
      # @return [nil]
      def delete_remote_link(issue_id_or_key, link_id)
        delete("/issue/#{url_encode(issue_id_or_key)}/remotelink/#{link_id}")
      end
    end
  end
end
