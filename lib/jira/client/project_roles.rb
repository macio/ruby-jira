# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to project roles.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-roles/
    module ProjectRoles
      # Returns the roles of a project as a map of role name to role URL
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-roles/#api-rest-api-3-project-projectidorkey-role-get
      #
      # @param project_id_or_key [Integer, String] The ID or key of the project
      # @return [Hash]
      def project_roles(project_id_or_key)
        get("/project/#{url_encode(project_id_or_key)}/role")
      end

      # Returns a project role with its actors
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-roles/#api-rest-api-3-project-projectidorkey-role-id-get
      #
      # @param project_id_or_key [Integer, String] The ID or key of the project
      # @param id [Integer, String] The ID of the project role
      # @param options [Hash] Query parameters (e.g. :excludeInactiveUsers)
      # @return [Hash]
      def project_role(project_id_or_key, id, options = {})
        get("/project/#{url_encode(project_id_or_key)}/role/#{url_encode(id)}", query: options)
      end
    end
  end
end
