# frozen_string_literal: true

require "json"

module Jira
  module Webhook
    # A parsed Jira webhook delivery for issue events.
    #
    # Jira posts a JSON body with `webhookEvent`, the `issue`, the acting `user`
    # and, for updates, a `changelog`.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/webhooks/
    class Event
      # Event types with a dedicated parser. Other events are returned as raw hashes.
      SUPPORTED_EVENTS = %w[jira:issue_created jira:issue_updated].freeze

      attr_reader :webhook_event, :issue, :user, :changelog, :timestamp

      # @param body [String, Hash] Raw JSON body or an already decoded hash
      # @return [Jira::Webhook::Event, Hash] An Event for issue created/updated; the decoded hash otherwise
      def self.parse(body)
        payload = body.is_a?(String) ? JSON.parse(body, symbolize_names: true) : body.transform_keys(&:to_sym)
        return payload unless SUPPORTED_EVENTS.include?(payload[:webhookEvent])

        new(payload)
      end

      def initialize(payload)
        @webhook_event = payload[:webhookEvent]
        @issue = payload[:issue]
        @user = payload[:user]
        @changelog = payload[:changelog]
        @timestamp = payload[:timestamp]
      end

      # @return [Boolean]
      def created?
        webhook_event == "jira:issue_created"
      end

      # @return [Boolean]
      def updated?
        webhook_event == "jira:issue_updated"
      end
    end
  end
end
