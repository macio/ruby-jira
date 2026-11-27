# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to user groups.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-groups/
    module Groups
      # Returns a group by name
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-groups/#api-rest-api-3-group-get
      #
      # @param name [String] The name of the group
      # @param options [Hash] Query parameters (e.g. :expand)
      # @return [Hash]
      def group(name, options = {})
        get("/group", query: { groupname: name }.merge(options))
      end

      # Returns the members of a group
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-groups/#api-rest-api-3-group-member-get
      #
      # @param name [String] The name of the group
      # @param options [Hash] Query parameters (e.g. :includeInactiveUsers, :startAt, :maxResults)
      # @return [Jira::PaginatedResponse]
      def group_members(name, options = {})
        get("/group/member", query: { groupname: name }.merge(options))
      end

      # Adds a user to a group
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-groups/#api-rest-api-3-group-user-post
      #
      # @param name [String] The name of the group
      # @param account_id [String] The account ID of the user
      # @return [Hash]
      def add_user_to_group(name, account_id)
        post("/group/user", query: { groupname: name }, body: { accountId: account_id })
      end

      # Removes a user from a group
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-groups/#api-rest-api-3-group-user-delete
      #
      # @param name [String] The name of the group
      # @param account_id [String] The account ID of the user
      # @return [Hash]
      def remove_user_from_group(name, account_id)
        delete("/group/user", query: { groupname: name, accountId: account_id })
      end
    end
  end
end
