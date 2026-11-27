# frozen_string_literal: true

require "uri"

module Jira
  module Live
    # Replaces personal data in recorded Jira payloads before they are written as fixtures.
    #
    # Values are replaced by JSON key, so data of other users (group members, role actors,
    # audit authors) is covered too. Account IDs found under known keys are also replaced
    # wherever they appear inside strings, e.g. in `self` URLs.
    class Sanitizer
      FAKE_EMAIL = "test.user@example.com"
      FAKE_HOST = "example.atlassian.net"
      FAKE_ACCOUNT_ID = "000000:00000000-0000-0000-0000-000000000000"
      FAKE_DISPLAY_NAME = "Test User"
      FAKE_IP = "0.0.0.0"

      FAKE_SITE = "example"

      ACCOUNT_ID_KEYS = %w[accountId authorAccountId authorKey].freeze
      VALUE_REPLACEMENTS = {
        "emailAddress" => FAKE_EMAIL,
        "displayName" => FAKE_DISPLAY_NAME,
        "remoteAddress" => FAKE_IP
      }.freeze
      DROPPED_KEYS = %w[avatarUrls].freeze

      def self.call(data, host:, email:)
        new(host: host, email: email).call(data)
      end

      def initialize(host:, email:)
        @host = host.to_s
        @site = @host.end_with?(".atlassian.net") ? @host.delete_suffix(".atlassian.net") : ""
        @email = email.to_s
        @account_ids = Set.new
      end

      def call(data)
        collect_account_ids(data)
        scrub(data)
      end

      private

      def collect_account_ids(node)
        case node
        when Hash
          node.each do |key, value|
            @account_ids << value if ACCOUNT_ID_KEYS.include?(key.to_s) && value.is_a?(String)
            collect_account_ids(value)
          end
        when Array
          node.each { |item| collect_account_ids(item) }
        end
      end

      def scrub(node)
        case node
        when Hash then scrub_hash(node)
        when Array then node.map { |item| scrub(item) }
        when String then scrub_string(node)
        else node
        end
      end

      def scrub_hash(hash)
        hash.each_with_object({}) do |(key, value), result|
          name = key.to_s
          next if DROPPED_KEYS.include?(name)

          result[key] = scrub_value(name, value)
        end
      end

      def scrub_value(name, value)
        return scrub(value) unless value.is_a?(String)
        return FAKE_ACCOUNT_ID if ACCOUNT_ID_KEYS.include?(name)

        VALUE_REPLACEMENTS.fetch(name) { scrub_string(value) }
      end

      def scrub_string(string)
        result = string.dup
        result = result.gsub(@host, FAKE_HOST) unless @host.empty?
        result = result.gsub(@email, FAKE_EMAIL) unless @email.empty?
        result = result.gsub(@site, FAKE_SITE) unless @site.empty?
        @account_ids.each do |id|
          result = result.gsub(id, FAKE_ACCOUNT_ID).gsub(URI.encode_www_form_component(id), FAKE_ACCOUNT_ID)
        end
        result
      end
    end
  end
end
