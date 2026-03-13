# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to time tracking.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-time-tracking/
    module TimeTracking
      # Returns the selected time tracking provider
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-time-tracking/#api-rest-api-3-configuration-timetracking-get
      #
      # @return [Hash]
      def time_tracking_provider
        get("/configuration/timetracking")
      end

      # Selects a time tracking provider
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-time-tracking/#api-rest-api-3-configuration-timetracking-put
      #
      # @param payload [Hash] Time tracking provider payload
      # @return [nil]
      def select_time_tracking_provider(payload = {})
        put("/configuration/timetracking", body: payload)
      end

      # Returns all available time tracking providers
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-time-tracking/#api-rest-api-3-configuration-timetracking-list-get
      #
      # @return [Array<Hash>]
      def time_tracking_providers
        get("/configuration/timetracking/list")
      end

      # Returns the shared time tracking settings
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-time-tracking/#api-rest-api-3-configuration-timetracking-options-get
      #
      # @return [Hash]
      def time_tracking_settings
        get("/configuration/timetracking/options")
      end

      # Sets the shared time tracking settings
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-time-tracking/#api-rest-api-3-configuration-timetracking-options-put
      #
      # @param payload [Hash] Time tracking configuration payload
      # @return [Hash]
      def set_time_tracking_settings(payload = {})
        put("/configuration/timetracking/options", body: payload)
      end
    end
  end
end
