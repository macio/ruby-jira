# frozen_string_literal: true

module Jira
  class Client
    # Defines methods for fetching changelogs of several history entries at once.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/
    module IssueChangelogs
      # Returns the changelog entries of an issue for the given changelog IDs
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-changelog-list-post
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param changelog_ids [Array<Integer>] Changelog IDs to fetch
      # @return [Jira::PaginatedResponse] The entries are under the `histories` key
      def issue_changelogs_by_ids(issue_id_or_key, changelog_ids)
        post("/issue/#{url_encode(issue_id_or_key)}/changelog/list", body: { changelogIds: changelog_ids })
      end
    end
  end
end
