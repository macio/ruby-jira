# frozen_string_literal: true

module Jira
  class Client
    # Defines bulk operations on issues.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-bulk-operations/
    module BulkIssues
      # Deletes several issues in one asynchronous operation
      #
      # The response contains a task ID of the submitted operation, not the result of the deletion.
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-bulk-operations/#api-rest-api-3-bulk-issues-delete-post
      #
      # @param issue_ids_or_keys [Array<String, Integer>] IDs or keys of the issues to delete
      # @param send_notification [Boolean] Whether to send a notification about the deletion
      # @return [Hash] Submitted operation with the `taskId` key
      def bulk_delete_issues(issue_ids_or_keys, send_notification: false)
        post(
          "/bulk/issues/delete",
          body: { selectedIssueIdsOrKeys: issue_ids_or_keys.map(&:to_s), sendBulkNotification: send_notification }
        )
      end
    end
  end
end
