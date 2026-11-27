# frozen_string_literal: true

module Jira
  module Live
    # Creates and tracks issues for a live run and removes them afterwards.
    #
    # Every issue gets the `ruby-jira-live` label, so issues left behind by an interrupted
    # run can be found by `sweep_stale!`. The label is matched exactly; a text search on
    # the summary does not work, because Jira indexes `ruby-jira-live-<time>` as one token.
    class RunScope
      LABEL = "ruby-jira-live"
      STALE_JQL = %(project = %<project>s AND labels = "#{LABEL}" AND created <= -1h).freeze

      class CleanupError < StandardError; end

      attr_reader :prefix

      def initialize(client: Jira, clock: Time, project: "TEST")
        @client = client
        @project = project
        @prefix = "#{LABEL}-#{clock.now.to_i}"
        @issue_keys = []
      end

      # Creates a labelled issue with the run prefix in its summary and tracks it for cleanup.
      def create_issue(summary, issuetype: "Task")
        issue = @client.create_issue(
          fields: {
            project:   { key: @project },
            issuetype: { name: issuetype },
            summary:   "#{prefix} #{summary}",
            labels:    [LABEL]
          }
        )
        track_issue(issue[:key])
      end

      def track_issue(key)
        @issue_keys << key
        key
      end

      # Deletes every tracked issue, newest first. Failures do not stop the loop;
      # they are raised together after all deletions were attempted.
      def cleanup!
        errors = @issue_keys.reverse.filter_map { |key| delete_issue(key) }
        @issue_keys.clear
        raise CleanupError, errors.join("\n") unless errors.empty?
      end

      # Deletes labelled issues left behind by earlier runs (older than one hour).
      def self.sweep_stale!(client: Jira, project: "TEST")
        jql = format(STALE_JQL, project: project)
        client.search_issues_jql(jql: jql, fields: "key").auto_paginate.each do |issue|
          client.delete_issue(issue[:key])
        rescue Jira::Error::NotFound
          nil
        end
      end

      private

      def delete_issue(key)
        @client.delete_issue(key)
        nil
      rescue Jira::Error::NotFound
        nil
      rescue StandardError => e
        "#{key}: #{e.class}: #{e.message}"
      end
    end
  end
end
