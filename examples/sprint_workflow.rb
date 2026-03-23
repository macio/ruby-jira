# frozen_string_literal: true

# Demonstrates using both the Jira Platform REST API v3 and the
# Jira Software Cloud REST API (agile) from a single client.
#
# Enable debug logging (shows all requests and responses):
#   JIRA_DEBUG=1 bundle exec ruby examples/sprint_workflow.rb
#
# Basic auth:
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_EMAIL=you@example.com \
#   JIRA_API_TOKEN=your-api-token \
#   JIRA_PROJECT_KEY=TEST \
#   JIRA_BOARD_ID=1 \
#   JIRA_SPRINT_ID=37 \
#   bundle exec ruby examples/sprint_workflow.rb
#
# OAuth2 with pre-fetched access token:
#   JIRA_AUTH_TYPE=oauth2 \
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_CLOUD_ID=your-cloud-id \
#   JIRA_OAUTH_ACCESS_TOKEN=your-access-token \
#   JIRA_PROJECT_KEY=TEST \
#   JIRA_SPRINT_ID=37 \
#   bundle exec ruby examples/sprint_workflow.rb

require "bundler/setup"
require "logger"
require_relative "../lib/jira"
require "pp"

AUTH_TYPE   = ENV.fetch("JIRA_AUTH_TYPE", "basic").to_sym
ENDPOINT    = ENV.fetch("JIRA_ENDPOINT")
PROJECT_KEY = ENV.fetch("JIRA_PROJECT_KEY", "TEST")
SPRINT_ID   = Integer(ENV.fetch("JIRA_SPRINT_ID"))

Jira.configure do |config|
  config.endpoint  = ENDPOINT
  config.auth_type = AUTH_TYPE

  case AUTH_TYPE
  when :basic
    config.email     = ENV.fetch("JIRA_EMAIL")
    config.api_token = ENV.fetch("JIRA_API_TOKEN")
  when :oauth2
    config.cloud_id              = ENV.fetch("JIRA_CLOUD_ID")
    config.oauth_access_token    = ENV.fetch("JIRA_OAUTH_ACCESS_TOKEN", nil)
    config.oauth_client_id       = ENV.fetch("JIRA_OAUTH_CLIENT_ID", nil)
    config.oauth_client_secret   = ENV.fetch("JIRA_OAUTH_CLIENT_SECRET", nil)
    config.oauth_refresh_token   = ENV.fetch("JIRA_OAUTH_REFRESH_TOKEN", nil)
    config.oauth_grant_type      = ENV.fetch("JIRA_OAUTH_GRANT_TYPE", nil)
    config.oauth_token_endpoint  = ENV.fetch(
      "JIRA_OAUTH_TOKEN_ENDPOINT",
      Jira::Configuration::DEFAULT_OAUTH_TOKEN_ENDPOINT
    )
  else
    raise ArgumentError, "Unsupported JIRA_AUTH_TYPE: #{AUTH_TYPE}"
  end

  config.logger = Logger.new($stdout).tap { |l| l.level = Logger::DEBUG } if ENV["JIRA_DEBUG"] == "1"
end

def section(title)
  puts "\n=== #{title} ==="
end

def show(value)
  pp value
  puts "class: #{value.class}"
end

# ── Platform REST API v3 ───────────────────────────────────────────────────────

section "Platform API — single project"
project = Jira.project(PROJECT_KEY)
show project
puts "name: #{project.name}, key: #{project.key}"

issue_key = ENV["JIRA_ISSUE_KEY"].to_s
unless issue_key.empty?
  section "Platform API — single issue: #{issue_key}"
  issue = Jira.issue(issue_key)
  show issue
  puts "summary: #{issue.fields.summary}"
end

# ── Jira Software Cloud REST API (agile) ──────────────────────────────────────

section "Agile API — get sprint #{SPRINT_ID}"
sprint = Jira.sprint(SPRINT_ID)
show sprint
puts "sprint name: #{sprint.name}, state: #{sprint.state}"

section "Agile API — sprint issues (first page)"
issues = Jira.sprint_issues(SPRINT_ID, maxResults: 10)
show issues
puts "total: #{issues.total}, page size: #{issues.size}"
issues.each { |i| puts "  #{i[:key]}" }

section "Agile API — sprint property keys"
show Jira.sprint_property_keys(SPRINT_ID)

# Optionally move an issue to the sprint
move_key = ENV["JIRA_MOVE_ISSUE_KEY"].to_s
unless move_key.empty?
  section "Agile API — move #{move_key} to sprint #{SPRINT_ID}"
  Jira.move_issues_to_sprint(SPRINT_ID, issues: [move_key])
  puts "done"
end
