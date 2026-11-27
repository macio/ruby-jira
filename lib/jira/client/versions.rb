# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to project versions.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-versions/
    module Versions
      # Creates a version
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-versions/#api-rest-api-3-version-post
      #
      # @param payload [Hash] Version payload (e.g. :name, :project or :projectId)
      # @return [Hash]
      def create_version(payload = {})
        post("/version", body: payload)
      end

      # Returns a version by ID
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-versions/#api-rest-api-3-version-id-get
      #
      # @param id [Integer, String] The ID of the version
      # @return [Hash]
      def version(id)
        get("/version/#{url_encode(id)}")
      end

      # Updates a version
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-versions/#api-rest-api-3-version-id-put
      #
      # @param id [Integer, String] The ID of the version
      # @param payload [Hash] Fields to update (e.g. :name, :released, :releaseDate)
      # @return [Hash]
      def update_version(id, payload = {})
        put("/version/#{url_encode(id)}", body: payload)
      end

      # Deletes a version
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-versions/#api-rest-api-3-version-id-delete
      #
      # @param id [Integer, String] The ID of the version
      # @return [Hash]
      def delete_version(id)
        delete("/version/#{url_encode(id)}")
      end

      # Returns all versions of a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-versions/#api-rest-api-3-project-projectidorkey-versions-get
      #
      # @param project_id_or_key [Integer, String] The ID or key of the project
      # @return [Array<Hash>]
      def project_versions(project_id_or_key)
        get("/project/#{url_encode(project_id_or_key)}/versions")
      end
    end
  end
end
