# frozen_string_literal: true

# Loaded only by files ending in _live_spec.rb. Those files are excluded from the default
# `rspec` run (.rspec) and run with `rake live` or by passing the file path explicitly.
#
# Live specs call the Jira test instance configured in .env and record sanitized fixtures
# for the unit specs. See TESTING.md.

require "spec_helper"
require "dotenv"
require "uri"
require_relative "support/live/sanitizer"
require_relative "support/live/run_scope"
require_relative "support/live/fixture_recorder"

SimpleCov.command_name "RSpec live"
Dotenv.load(File.expand_path("../.env", __dir__))

module Jira
  module Live
    ALLOWED_HOSTS = %w[pinokio.atlassian.net].freeze
    REQUIRED_ENV = %w[JIRA_ENDPOINT JIRA_EMAIL JIRA_API_TOKEN].freeze
    PROJECT_KEY = "TEST"
    REQUIRED_PERMISSIONS = %w[CREATE_ISSUES EDIT_ISSUES DELETE_ISSUES].freeze

    class SetupError < StandardError; end

    def self.configure!
      check_environment!
      apply_configuration!
    end

    def self.check_environment!
      missing = REQUIRED_ENV.select { |name| ENV.fetch(name, "").empty? }
      raise SetupError, "Live specs need #{missing.join(", ")} in .env or the environment" unless missing.empty?

      host = URI(ENV.fetch("JIRA_ENDPOINT")).host
      return if ALLOWED_HOSTS.include?(host)

      raise SetupError, "Live specs refuse to run against #{host}; allowed: #{ALLOWED_HOSTS.join(", ")}"
    end

    def self.apply_configuration!
      Jira.endpoint = ENV.fetch("JIRA_ENDPOINT")
      Jira.auth_type = :basic
      Jira.email = ENV.fetch("JIRA_EMAIL")
      Jira.api_token = ENV.fetch("JIRA_API_TOKEN")
      Jira.oauth_access_token = nil
      Jira.cloud_id = nil
    end

    def self.preflight!
      result = Jira.client.get(
        "/mypermissions",
        query: { projectKey: PROJECT_KEY, permissions: REQUIRED_PERMISSIONS.join(",") }
      )
      missing = result[:permissions].to_h.reject { |_name, permission| permission[:havePermission] }.keys
      return if missing.empty?

      raise SetupError, "The live test account lacks #{missing.join(", ")} in project #{PROJECT_KEY}"
    end
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: /_live_spec\.rb\z/) { |metadata| metadata[:live] = true }
  config.include Jira::Live::FixtureRecorder, :live

  config.before(:suite) do
    next unless RSpec.world.example_groups.any? { |group| group.metadata[:live] }

    WebMock.allow_net_connect!
    Jira::Live.configure!
    Jira::Live.preflight!
    Jira::Live::RunScope.sweep_stale!(project: Jira::Live::PROJECT_KEY)
  ensure
    WebMock.disable_net_connect!
  end

  config.before(:all, :live) do
    Jira::Live.configure!
    WebMock.allow_net_connect!
  end

  config.after(:all, :live) { WebMock.disable_net_connect! }
end
