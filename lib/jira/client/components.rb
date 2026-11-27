# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to project components.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-components/
    module Components
      # Creates a component
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-components/#api-rest-api-3-component-post
      #
      # @param payload [Hash] Component payload (e.g. :name, :project or :projectId)
      # @return [Hash]
      def create_component(payload = {})
        post("/component", body: payload)
      end

      # Returns a component by ID
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-components/#api-rest-api-3-component-id-get
      #
      # @param id [Integer, String] The ID of the component
      # @return [Hash]
      def component(id)
        get("/component/#{url_encode(id)}")
      end

      # Updates a component
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-components/#api-rest-api-3-component-id-put
      #
      # @param id [Integer, String] The ID of the component
      # @param payload [Hash] Fields to update (e.g. :name, :description)
      # @return [Hash]
      def update_component(id, payload = {})
        put("/component/#{url_encode(id)}", body: payload)
      end

      # Deletes a component
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-components/#api-rest-api-3-component-id-delete
      #
      # @param id [Integer, String] The ID of the component
      # @return [Hash]
      def delete_component(id)
        delete("/component/#{url_encode(id)}")
      end

      # Returns all components of a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-components/#api-rest-api-3-project-projectidorkey-components-get
      #
      # @param project_id_or_key [Integer, String] The ID or key of the project
      # @return [Array<Hash>]
      def project_components(project_id_or_key)
        get("/project/#{url_encode(project_id_or_key)}/components")
      end
    end
  end
end
