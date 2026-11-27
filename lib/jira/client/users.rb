# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to users.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-users/
    module Users
      # Returns the user associated with the credentials used for the request
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-myself/#api-rest-api-3-myself-get
      #
      # @param options [Hash] Query parameters
      # @return [Hash]
      def myself(options = {})
        get("/myself", query: options)
      end

      # Returns a user by account ID
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-users/#api-rest-api-3-user-get
      #
      # @param account_id [String] The account ID of the user
      # @param options [Hash] Query parameters
      # @return [Hash]
      def user(account_id, options = {})
        get("/user", query: { accountId: account_id }.merge(options))
      end

      # Searches for users matching a query string
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-users/#api-rest-api-3-user-search-get
      #
      # @param query [String] Text to match against display name or email
      # @param options [Hash] Query parameters
      # @return [Array<Hash>]
      def user_search(query, options = {})
        get("/user/search", query: { query: query }.merge(options))
      end

      # Returns users that can be assigned to issues in a project or for an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-users/#api-rest-api-3-user-assignable-search-get
      #
      # @param options [Hash] Query parameters (e.g. :project, :issueKey, :query)
      # @return [Array<Hash>]
      def user_assignable_search(options = {})
        get("/user/assignable/search", query: options)
      end
    end
  end
end
