# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to project permission schemes.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-permission-schemes/
    module ProjectPermissionSchemes
      # Gets assigned issue security level scheme for a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-permission-schemes/#api-rest-api-3-project-projectkeyorid-issuesecuritylevelscheme-get
      #
      # @param project_key_or_id [Integer, String] Project ID or key
      # @param options [Hash] Query parameters
      # @return [Hash]
      def issue_security_level_scheme(project_key_or_id, options = {})
        get("/project/#{url_encode(project_key_or_id)}/issuesecuritylevelscheme", query: options)
      end

      # Gets assigned permission scheme for a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-permission-schemes/#api-rest-api-3-project-projectkeyorid-permissionscheme-get
      #
      # @param project_key_or_id [Integer, String] Project ID or key
      # @param options [Hash] Query parameters
      # @return [Hash]
      def permission_scheme(project_key_or_id, options = {})
        get("/project/#{url_encode(project_key_or_id)}/permissionscheme", query: options)
      end

      # Assigns permission scheme to a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-permission-schemes/#api-rest-api-3-project-projectkeyorid-permissionscheme-put
      #
      # @param project_key_or_id [Integer, String] Project ID or key
      # @param scheme_id [Integer] Permission scheme ID
      # @param options [Hash] Additional payload
      # @return [Hash]
      def assign_permission_scheme(project_key_or_id, scheme_id:, options: {})
        body = { id: scheme_id }.merge(options)
        put("/project/#{url_encode(project_key_or_id)}/permissionscheme", body: body)
      end
    end
  end
end
