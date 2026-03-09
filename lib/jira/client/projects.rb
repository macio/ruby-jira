# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to projects.
    module Projects
      # Search projects
      #
      # @param options [Hash] Query parameters
      # @return [Jira::Request::PaginatedResponse]
      def projects(options = {})
        get("/project/search", query: options)
      end

      # Gets a single project
      #
      # @param project_id_or_key [Integer, String] Project ID or key
      # @param options [Hash] Query parameters
      # @return [Hash]
      def project(project_id_or_key, options = {})
        get("/project/#{url_encode(project_id_or_key)}", query: options)
      end

      # Archives a project
      #
      # @param project_id_or_key [Integer, String] Project ID or key
      # @return [Hash]
      def archive_project(project_id_or_key)
        post("/project/#{url_encode(project_id_or_key)}/archive")
      end
    end
  end
end
