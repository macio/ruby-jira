# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to boards (Jira Software Cloud API).
    #
    # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/
    module Boards
      # Returns all boards
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-get
      #
      # @param options [Hash] Query parameters (startAt:, maxResults:, type:, name:, projectKeyOrId:, ...)
      # @return [Jira::PaginatedResponse]
      def boards(options = {})
        agile_get("/board", query: options)
      end

      # Creates a new board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-post
      #
      # @param payload [Hash] Board payload (name:, type:, filterId:, location:)
      # @return [Hash]
      def create_board(payload = {})
        agile_post("/board", body: payload)
      end

      # Returns all boards for the given filter
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-filter-filterid-get
      #
      # @param filter_id [Integer] The ID of the filter
      # @param options [Hash] Query parameters (startAt:, maxResults:)
      # @return [Jira::PaginatedResponse]
      def boards_for_filter(filter_id, options = {})
        agile_get("/board/filter/#{filter_id}", query: options)
      end

      # Returns the board for the given board ID
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-get
      #
      # @param board_id [Integer] The ID of the board
      # @return [Hash]
      def board(board_id)
        agile_get("/board/#{board_id}")
      end

      # Deletes the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-delete
      #
      # @param board_id [Integer] The ID of the board
      # @return [nil]
      def delete_board(board_id)
        agile_delete("/board/#{board_id}")
      end

      # Returns all issues in the backlog of the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-backlog-get
      #
      # @param board_id [Integer] The ID of the board
      # @param options [Hash] Query parameters (startAt:, maxResults:, jql:, fields:, ...)
      # @return [Jira::PaginatedResponse]
      def board_backlog(board_id, options = {})
        agile_get("/board/#{board_id}/backlog", query: options)
      end

      # Returns the configuration of the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-configuration-get
      #
      # @param board_id [Integer] The ID of the board
      # @return [Hash]
      def board_configuration(board_id)
        agile_get("/board/#{board_id}/configuration")
      end

      # Returns all epics from the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-epic-get
      #
      # @param board_id [Integer] The ID of the board
      # @param options [Hash] Query parameters (startAt:, maxResults:, done:)
      # @return [Jira::PaginatedResponse]
      def board_epics(board_id, options = {})
        agile_get("/board/#{board_id}/epic", query: options)
      end

      # Returns all issues that do not belong to any epic on the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-epic-none-issue-get
      #
      # @param board_id [Integer] The ID of the board
      # @param options [Hash] Query parameters (startAt:, maxResults:, jql:, fields:, ...)
      # @return [Jira::PaginatedResponse]
      def board_issues_without_epic(board_id, options = {})
        agile_get("/board/#{board_id}/epic/none/issue", query: options)
      end

      # Returns all issues that belong to the given epic on the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-epic-epicid-issue-get
      #
      # @param board_id [Integer] The ID of the board
      # @param epic_id [Integer] The ID of the epic
      # @param options [Hash] Query parameters (startAt:, maxResults:, jql:, fields:, ...)
      # @return [Jira::PaginatedResponse]
      def board_epic_issues(board_id, epic_id, options = {})
        agile_get("/board/#{board_id}/epic/#{epic_id}/issue", query: options)
      end

      # Returns the features enabled/disabled for the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-features-get
      #
      # @param board_id [Integer] The ID of the board
      # @return [Hash]
      def board_features(board_id)
        agile_get("/board/#{board_id}/features")
      end

      # Toggles a feature on or off for the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-features-put
      #
      # @param board_id [Integer] The ID of the board
      # @param payload [Hash] Feature toggle payload (feature:, state:)
      # @return [Hash]
      def toggle_board_feature(board_id, payload = {})
        agile_put("/board/#{board_id}/features", body: payload)
      end

      # Returns all issues from the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-issue-get
      #
      # @param board_id [Integer] The ID of the board
      # @param options [Hash] Query parameters (startAt:, maxResults:, jql:, fields:, ...)
      # @return [Jira::PaginatedResponse]
      def board_issues(board_id, options = {})
        agile_get("/board/#{board_id}/issue", query: options)
      end

      # Moves issues to the backlog of the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-issue-post
      #
      # @param board_id [Integer] The ID of the board
      # @param issues [Array<String>] List of issue keys or IDs
      # @return [nil]
      def move_issues_to_board(board_id, issues:)
        agile_post("/board/#{board_id}/issue", body: { issues: issues })
      end

      # Returns all projects that are associated with the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-project-get
      #
      # @param board_id [Integer] The ID of the board
      # @param options [Hash] Query parameters (startAt:, maxResults:)
      # @return [Jira::PaginatedResponse]
      def board_projects(board_id, options = {})
        agile_get("/board/#{board_id}/project", query: options)
      end

      # Returns all projects that are associated with the board, including all issue types
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-project-full-get
      #
      # @param board_id [Integer] The ID of the board
      # @param options [Hash] Query parameters (startAt:, maxResults:)
      # @return [Jira::PaginatedResponse]
      def board_projects_full(board_id, options = {})
        agile_get("/board/#{board_id}/project/full", query: options)
      end

      # Returns the keys of all properties for the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-properties-get
      #
      # @param board_id [Integer] The ID of the board
      # @return [Hash]
      def board_property_keys(board_id)
        agile_get("/board/#{board_id}/properties")
      end

      # Returns the value of the property with the given key for the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-properties-propertykey-get
      #
      # @param board_id [Integer] The ID of the board
      # @param property_key [String] The key of the property
      # @return [Hash]
      def board_property(board_id, property_key)
        agile_get("/board/#{board_id}/properties/#{url_encode(property_key)}")
      end

      # Sets the value of the property with the given key for the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-properties-propertykey-put
      #
      # @param board_id [Integer] The ID of the board
      # @param property_key [String] The key of the property
      # @param value [Hash] The value to set
      # @return [nil]
      def set_board_property(board_id, property_key, value = {})
        agile_put("/board/#{board_id}/properties/#{url_encode(property_key)}", body: value)
      end

      # Deletes the property with the given key for the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-properties-propertykey-delete
      #
      # @param board_id [Integer] The ID of the board
      # @param property_key [String] The key of the property
      # @return [nil]
      def delete_board_property(board_id, property_key)
        agile_delete("/board/#{board_id}/properties/#{url_encode(property_key)}")
      end

      # Returns all quick filters of the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-quickfilter-get
      #
      # @param board_id [Integer] The ID of the board
      # @param options [Hash] Query parameters (startAt:, maxResults:)
      # @return [Jira::PaginatedResponse]
      def board_quick_filters(board_id, options = {})
        agile_get("/board/#{board_id}/quickfilter", query: options)
      end

      # Returns the quick filter for the given board and quick filter ID
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-quickfilter-quickfilterid-get
      #
      # @param board_id [Integer] The ID of the board
      # @param quick_filter_id [Integer] The ID of the quick filter
      # @return [Hash]
      def board_quick_filter(board_id, quick_filter_id)
        agile_get("/board/#{board_id}/quickfilter/#{quick_filter_id}")
      end

      # Returns the board reports
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-reports-get
      #
      # @param board_id [Integer] The ID of the board
      # @return [Hash]
      def board_reports(board_id)
        agile_get("/board/#{board_id}/reports")
      end

      # Returns all sprints from the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-sprint-get
      #
      # @param board_id [Integer] The ID of the board
      # @param options [Hash] Query parameters (startAt:, maxResults:, state:)
      # @return [Jira::PaginatedResponse]
      def board_sprints(board_id, options = {})
        agile_get("/board/#{board_id}/sprint", query: options)
      end

      # Returns all issues in the sprint for the given board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-sprint-sprintid-issue-get
      #
      # @param board_id [Integer] The ID of the board
      # @param sprint_id [Integer] The ID of the sprint
      # @param options [Hash] Query parameters (startAt:, maxResults:, jql:, fields:, ...)
      # @return [Jira::PaginatedResponse]
      def board_sprint_issues(board_id, sprint_id, options = {})
        agile_get("/board/#{board_id}/sprint/#{sprint_id}/issue", query: options)
      end

      # Returns all versions from the board
      #
      # @url https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/#api-rest-agile-1-0-board-boardid-version-get
      #
      # @param board_id [Integer] The ID of the board
      # @param options [Hash] Query parameters (startAt:, maxResults:, released:)
      # @return [Jira::PaginatedResponse]
      def board_versions(board_id, options = {})
        agile_get("/board/#{board_id}/version", query: options)
      end
    end
  end
end
