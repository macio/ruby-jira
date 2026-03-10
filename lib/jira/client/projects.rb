# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to projects.
    module Projects
      # Search projects
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-projects/#api-rest-api-3-project-search-get
      #
      # @param options [Hash] Query parameters
      # @return [Jira::Request::PaginatedResponse]
      def projects(options = {})
        get("/project/search", query: options)
      end

      # Gets a single project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-projects/#api-rest-api-3-project-projectidorkey-get
      #
      # @param project_id_or_key [Integer, String] Project ID or key
      # @param options [Hash] Query parameters
      # @return [Hash]
      def project(project_id_or_key, options = {})
        get("/project/#{url_encode(project_id_or_key)}", query: options)
      end

      # Archives a project
      #
      # https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-projects/#api-rest-api-3-project-projectidorkey-archive-post
      #
      # @param project_id_or_key [Integer, String] Project ID or key
      # @return [Hash]
      def archive_project(project_id_or_key)
        post("/project/#{url_encode(project_id_or_key)}/archive")
      end

      # Updates a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-projects/#api-rest-api-3-project-projectidorkey-put
      #
      # @param project_id_or_key [Integer, String] Project ID or key
      # @param payload [Hash] Fields to update
      # @return [Hash]
      def update_project(project_id_or_key, payload = {})
        put("/project/#{url_encode(project_id_or_key)}", body: payload)
      end

      # Deletes a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-projects/#api-rest-api-3-project-projectidorkey-delete
      #
      # @param project_id_or_key [Integer, String] Project ID or key
      # @return [Hash]
      def delete_project(project_id_or_key)
        delete("/project/#{url_encode(project_id_or_key)}")
      end

      # Gets all issue types with their statuses for a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-projects/#api-rest-api-3-project-projectidorkey-statuses-get
      #
      # @param project_id_or_key [Integer, String] Project ID or key
      # @return [Array<Hash>]
      def project_statuses(project_id_or_key)
        get("/project/#{url_encode(project_id_or_key)}/statuses")
      end

      # Gets the issue type hierarchy for a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-projects/#api-rest-api-3-project-projectid-hierarchy-get
      #
      # @param project_id [Integer, String] Project ID
      # @return [Hash]
      def project_issue_type_hierarchy(project_id)
        get("/project/#{url_encode(project_id)}/hierarchy")
      end

      # Gets the notification scheme for a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-projects/#api-rest-api-3-project-projectkeyorid-notificationscheme-get
      #
      # @param project_key_or_id [Integer, String] Project key or ID
      # @param options [Hash] Query parameters (e.g. expand:)
      # @return [Hash]
      def project_notification_scheme(project_key_or_id, options = {})
        get("/project/#{url_encode(project_key_or_id)}/notificationscheme", query: options)
      end
    end
  end
end
