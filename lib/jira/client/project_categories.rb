# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to project categories.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-categories/
    module ProjectCategories
      # Returns all project categories
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-categories/#api-rest-api-3-projectcategory-get
      #
      # @return [Array<Hash>]
      def project_categories
        get("/projectCategory")
      end

      # Creates a project category
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-categories/#api-rest-api-3-projectcategory-post
      #
      # @param payload [Hash] Project category payload
      # @return [Hash]
      def create_project_category(payload = {})
        post("/projectCategory", body: payload)
      end

      # Returns a project category by ID
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-categories/#api-rest-api-3-projectcategory-id-get
      #
      # @param id [Integer, String] The ID of the project category
      # @return [Hash]
      def project_category(id)
        get("/projectCategory/#{url_encode(id)}")
      end

      # Updates a project category
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-categories/#api-rest-api-3-projectcategory-id-put
      #
      # @param id [Integer, String] The ID of the project category
      # @param payload [Hash] Project category payload
      # @return [Hash]
      def update_project_category(id, payload = {})
        put("/projectCategory/#{url_encode(id)}", body: payload)
      end

      # Deletes a project category
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-project-categories/#api-rest-api-3-projectcategory-id-delete
      #
      # @param id [Integer, String] The ID of the project category
      # @return [nil]
      def delete_project_category(id)
        delete("/projectCategory/#{url_encode(id)}")
      end
    end
  end
end
