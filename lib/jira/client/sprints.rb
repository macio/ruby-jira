# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to sprints (Jira Software Cloud API).
    #
    # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/
    module Sprints
      # Creates a sprint
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-post
      #
      # @param payload [Hash] Sprint payload (name:, originBoardId:, goal:, startDate:, endDate:)
      # @return [Hash]
      def create_sprint(payload = {})
        agile_post("/sprint", body: payload)
      end

      # Gets a sprint by ID
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-get
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @return [Hash]
      def sprint(sprint_id)
        agile_get("/sprint/#{sprint_id}")
      end

      # Partially updates a sprint
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-post
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @param payload [Hash] Fields to update
      # @return [Hash]
      def update_sprint(sprint_id, payload = {})
        agile_post("/sprint/#{sprint_id}", body: payload)
      end

      # Fully updates a sprint (all fields required)
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-put
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @param payload [Hash] Full sprint payload
      # @return [Hash]
      def replace_sprint(sprint_id, payload = {})
        agile_put("/sprint/#{sprint_id}", body: payload)
      end

      # Deletes a sprint
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-delete
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @return [nil]
      def delete_sprint(sprint_id)
        agile_delete("/sprint/#{sprint_id}")
      end

      # Gets paginated issues for a sprint
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-issue-get
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @param options [Hash] Query parameters (startAt:, maxResults:, jql:, fields:)
      # @return [Jira::PaginatedResponse]
      def sprint_issues(sprint_id, options = {})
        agile_get("/sprint/#{sprint_id}/issue", query: options)
      end

      # Moves issues to a sprint
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-issue-post
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @param issues [Array<String>] List of issue keys or IDs
      # @return [nil]
      def move_issues_to_sprint(sprint_id, issues:)
        agile_post("/sprint/#{sprint_id}/issue", body: { issues: issues })
      end

      # Gets property keys for a sprint
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-properties-get
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @return [Hash]
      def sprint_property_keys(sprint_id)
        agile_get("/sprint/#{sprint_id}/properties")
      end

      # Gets a single sprint property
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-properties-propertykey-get
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @param property_key [String] The property key
      # @return [Hash]
      def sprint_property(sprint_id, property_key)
        agile_get("/sprint/#{sprint_id}/properties/#{url_encode(property_key)}")
      end

      # Sets or updates a sprint property
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-properties-propertykey-put
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @param property_key [String] The property key
      # @param value [Hash] The property value
      # @return [nil]
      def set_sprint_property(sprint_id, property_key, value = {})
        agile_put("/sprint/#{sprint_id}/properties/#{url_encode(property_key)}", body: value)
      end

      # Deletes a sprint property
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-properties-propertykey-delete
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @param property_key [String] The property key
      # @return [nil]
      def delete_sprint_property(sprint_id, property_key)
        agile_delete("/sprint/#{sprint_id}/properties/#{url_encode(property_key)}")
      end

      # Swaps the position of a sprint with another sprint
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/#api-rest-agile-1-0-sprint-sprintid-swap-post
      #
      # @param sprint_id [Integer] The ID of the sprint
      # @param sprint_to_swap_with [Integer] The ID of the sprint to swap with
      # @return [nil]
      def swap_sprint(sprint_id, sprint_to_swap_with:)
        agile_post("/sprint/#{sprint_id}/swap", body: { sprintToSwapWith: sprint_to_swap_with })
      end
    end
  end
end
