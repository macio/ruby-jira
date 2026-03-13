# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to project properties.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-properties/
    module ProjectProperties
      # Returns all property keys for a project
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-properties/#api-rest-api-3-project-projectidorkey-properties-get
      #
      # @param project_id_or_key [Integer, String] The ID or key of the project
      # @return [Hash]
      def project_property_keys(project_id_or_key)
        get("/project/#{url_encode(project_id_or_key)}/properties")
      end

      # Returns the value of a project property
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-properties/#api-rest-api-3-project-projectidorkey-properties-propertykey-get
      #
      # @param project_id_or_key [Integer, String] The ID or key of the project
      # @param property_key [String] The key of the property
      # @return [Hash]
      def project_property(project_id_or_key, property_key)
        get("/project/#{url_encode(project_id_or_key)}/properties/#{url_encode(property_key)}")
      end

      # Sets the value of a project property
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-properties/#api-rest-api-3-project-projectidorkey-properties-propertykey-put
      #
      # @param project_id_or_key [Integer, String] The ID or key of the project
      # @param property_key [String] The key of the property
      # @param payload [Hash] The value to set
      # @return [nil]
      def set_project_property(project_id_or_key, property_key, payload = {})
        put("/project/#{url_encode(project_id_or_key)}/properties/#{url_encode(property_key)}", body: payload)
      end

      # Deletes a project property
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-properties/#api-rest-api-3-project-projectidorkey-properties-propertykey-delete
      #
      # @param project_id_or_key [Integer, String] The ID or key of the project
      # @param property_key [String] The key of the property
      # @return [nil]
      def delete_project_property(project_id_or_key, property_key)
        delete("/project/#{url_encode(project_id_or_key)}/properties/#{url_encode(property_key)}")
      end
    end
  end
end
