# frozen_string_literal: true

module Jira
  module Live
    # Tracks issues created by a live run and removes them afterwards.
    #
    # Every issue gets a summary starting with `prefix`, so issues left behind by an
    # interrupted run can be found and removed by `sweep_stale!`.
    class RunScope
      PREFIX = "ruby-jira-live"
      STALE_JQL = %(project = %<project>s AND summary ~ "#{PREFIX}" AND created <= -1h).freeze

      class CleanupError < StandardError; end

      attr_reader :prefix

      def initialize(client: Jira, clock: Time)
        @client = client
        @prefix = "#{PREFIX}-#{clock.now.to_i}"
        @issue_keys = []
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

      # Deletes issues left behind by earlier runs (older than one hour).
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
