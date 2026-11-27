# frozen_string_literal: true

module Jira
  class Client
    # Defines methods returning field metadata required to create issues.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/
    module Metadata
      # Returns issue types of a project with their create-screen field metadata
      #
      # The items are the entries of the `issueTypes` array. The OpenAPI spec also lists
      # `createMetaIssueType`, but Jira Cloud does not return it.
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-createmeta-projectidorkey-issuetypes-get
      #
      # @param project_id_or_key [Integer, String] The ID or key of the project
      # @param options [Hash] Query parameters (e.g. :startAt, :maxResults)
      # @return [Jira::PaginatedResponse]
      def create_metadata(project_id_or_key, options = {})
        get("/issue/createmeta/#{url_encode(project_id_or_key)}/issuetypes", query: options)
      end

      # Returns the create-screen field metadata for one issue type of a project
      #
      # The items are the entries of the `fields` array. The OpenAPI spec also lists
      # `results`, but Jira Cloud does not return it.
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-createmeta-projectidorkey-issuetypes-issuetypeid-get
      #
      # @param project_id_or_key [Integer, String] The ID or key of the project
      # @param issue_type_id [Integer, String] The ID of the issue type
      # @param options [Hash] Query parameters (e.g. :startAt, :maxResults)
      # @return [Jira::PaginatedResponse]
      def create_metadata_for_issue_type(project_id_or_key, issue_type_id, options = {})
        get(
          "/issue/createmeta/#{url_encode(project_id_or_key)}/issuetypes/#{url_encode(issue_type_id)}",
          query: options
        )
      end
    end
  end
end
