# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to links between issues.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-links/
    module IssueLinks
      # Creates a link between two issues
      #
      # The response has an empty body (HTTP 201).
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-links/#api-rest-api-3-issuelink-post
      #
      # @param payload [Hash] Link payload with :type, :inwardIssue, :outwardIssue and optional :comment
      # @return [Hash]
      def create_issue_link(payload = {})
        post("/issueLink", body: payload)
      end

      # Returns an issue link by ID
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-links/#api-rest-api-3-issuelink-linkid-get
      #
      # @param link_id [Integer, String] The ID of the issue link
      # @return [Hash]
      def issue_link(link_id)
        get("/issueLink/#{url_encode(link_id)}")
      end

      # Deletes an issue link
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-links/#api-rest-api-3-issuelink-linkid-delete
      #
      # @param link_id [Integer, String] The ID of the issue link
      # @return [Hash]
      def delete_issue_link(link_id)
        delete("/issueLink/#{url_encode(link_id)}")
      end

      # Returns all issue link types. The items are under the `issueLinkTypes` key.
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-link-types/#api-rest-api-3-issuelinktype-get
      #
      # @return [Hash]
      def issue_link_types
        get("/issueLinkType")
      end
    end
  end
end
