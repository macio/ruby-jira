# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to issues.
    module Issues
      # Creates a new issue
      #
      # @param payload [Hash] Issue payload
      # @return [Hash]
      def create_issue(payload = {})
        post("/issue", body: payload)
      end

      # Gets a single issue
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param options [Hash] Query parameters
      # @return [Hash]
      def issue(issue_id_or_key, options = {})
        get("/issue/#{url_encode(issue_id_or_key)}", query: options)
      end

      # Updates an existing issue
      #
      # @param issue_id_or_key [Integer, String] The ID or key of an issue
      # @param payload [Hash] Issue payload
      # @param options [Hash] Query parameters
      # @return [Hash]
      def edit_issue(issue_id_or_key, payload = {}, options = {})
        put("/issue/#{url_encode(issue_id_or_key)}", body: payload, query: options)
      end
    end
  end
end
