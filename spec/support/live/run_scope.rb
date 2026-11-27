# frozen_string_literal: true

module Jira
  module Live
    # Creates and tracks data for a live run and removes it afterwards.
    #
    # Every issue gets the `ruby-jira-live` label, so issues left behind by an interrupted
    # run can be found by `sweep_stale!`. The label is matched exactly; a text search on
    # the summary does not work, because Jira indexes `ruby-jira-live-<time>` as one token.
    # Versions and components carry the run prefix in their name for the same purpose.
    class RunScope
      LABEL = "ruby-jira-live"
      STALE_AFTER = 3600
      STALE_JQL = %(project = %<project>s AND labels = "#{LABEL}" AND created <= -1h).freeze
      PREFIXED_NAME = /\A#{LABEL}-(\d+)\b/

      class CleanupError < StandardError; end

      attr_reader :prefix

      def initialize(client: Jira, clock: Time, project: "TEST")
        @client = client
        @project = project
        @prefix = "#{LABEL}-#{clock.now.to_i}"
        @issue_keys = []
        @cleanups = []
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

      # Registers cleanup for data other than issues, e.g. `on_cleanup("version 1") { delete_version(1) }`.
      def on_cleanup(description, &block)
        @cleanups << [description, block]
      end

      # Runs registered cleanups, then deletes tracked issues, newest first. Failures do not
      # stop the loop; they are raised together after everything was attempted.
      def cleanup!
        errors = @cleanups.reverse.filter_map { |description, block| attempt(description, &block) }
        errors += @issue_keys.reverse.filter_map { |key| attempt(key) { @client.delete_issue(key) } }
        @cleanups.clear
        @issue_keys.clear
        raise CleanupError, errors.join("\n") unless errors.empty?
      end

      # Deletes data left behind by earlier runs (older than one hour): labelled issues and
      # versions or components whose name starts with the run prefix.
      def self.sweep_stale!(client: Jira, project: "TEST", clock: Time)
        sweep_issues(client, project)
        stale_named(client.project_versions(project), clock).each do |v|
          ignore_missing do
            client.delete_version(v[:id])
          end
        end
        stale_named(client.project_components(project), clock).each do |c|
          ignore_missing { client.delete_component(c[:id]) }
        end
      end

      def self.sweep_issues(client, project)
        client.search_issues_jql(jql: format(STALE_JQL, project: project), fields: "key").auto_paginate.each do |issue|
          ignore_missing { client.delete_issue(issue[:key]) }
        end
      end

      def self.stale_named(records, clock)
        records.select do |record|
          started_at = record[:name].to_s[PREFIXED_NAME, 1]
          started_at && clock.now.to_i - started_at.to_i > STALE_AFTER
        end
      end

      def self.ignore_missing
        yield
      rescue Jira::Error::NotFound
        nil
      end

      private

      def attempt(description)
        yield
        nil
      rescue Jira::Error::NotFound
        nil
      rescue StandardError => e
        "#{description}: #{e.class}: #{e.message}"
      end
    end
  end
end
