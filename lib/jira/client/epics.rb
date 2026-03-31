# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to epics (Jira Software Cloud API).
    #
    # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-epic/
    module Epics
      # Returns all issues that do not belong to any epic
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-epic/#api-rest-agile-1-0-epic-none-issue-get
      #
      # @param options [Hash] Query parameters (startAt:, maxResults:, jql:, fields:, ...)
      # @return [Jira::PaginatedResponse]
      def issues_without_epic(options = {})
        agile_get("/epic/none/issue", query: options)
      end

      # Removes issues from their epic (moves them to no epic)
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-epic/#api-rest-agile-1-0-epic-none-issue-post
      #
      # @param issues [Array<String>] List of issue keys or IDs
      # @return [nil]
      def unassign_issues_from_epic(issues:)
        agile_post("/epic/none/issue", body: { issues: issues })
      end

      # Returns the epic for the given epic ID or key
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-epic/#api-rest-agile-1-0-epic-epicidorkey-get
      #
      # @param epic_id_or_key [Integer, String] The ID or key of the epic
      # @return [Hash]
      def epic(epic_id_or_key)
        agile_get("/epic/#{url_encode(epic_id_or_key)}")
      end

      # Partially updates an epic
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-epic/#api-rest-agile-1-0-epic-epicidorkey-post
      #
      # @param epic_id_or_key [Integer, String] The ID or key of the epic
      # @param payload [Hash] Fields to update (name:, summary:, color:, done:)
      # @return [Hash]
      def update_epic(epic_id_or_key, payload = {})
        agile_post("/epic/#{url_encode(epic_id_or_key)}", body: payload)
      end

      # Returns all issues that belong to the given epic
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-epic/#api-rest-agile-1-0-epic-epicidorkey-issue-get
      #
      # @param epic_id_or_key [Integer, String] The ID or key of the epic
      # @param options [Hash] Query parameters (startAt:, maxResults:, jql:, fields:, ...)
      # @return [Jira::PaginatedResponse]
      def epic_issues(epic_id_or_key, options = {})
        agile_get("/epic/#{url_encode(epic_id_or_key)}/issue", query: options)
      end

      # Moves issues to an epic
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-epic/#api-rest-agile-1-0-epic-epicidorkey-issue-post
      #
      # @param epic_id_or_key [Integer, String] The ID or key of the epic
      # @param issues [Array<String>] List of issue keys or IDs
      # @return [nil]
      def move_issues_to_epic(epic_id_or_key, issues:)
        agile_post("/epic/#{url_encode(epic_id_or_key)}/issue", body: { issues: issues })
      end

      # Ranks the epic before or after a given epic
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-epic/#api-rest-agile-1-0-epic-epicidorkey-rank-put
      #
      # @param epic_id_or_key [Integer, String] The ID or key of the epic
      # @param payload [Hash] Rank payload (rankBeforeEpic:, rankAfterEpic:, rankCustomFieldId:)
      # @return [nil]
      def rank_epic(epic_id_or_key, payload = {})
        agile_put("/epic/#{url_encode(epic_id_or_key)}/rank", body: payload)
      end
    end
  end
end
