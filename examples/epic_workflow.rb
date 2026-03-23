# frozen_string_literal: true

# Demonstrates using the Jira Software Cloud REST API (agile) to work with epics.
# Discovers epics dynamically via boards - no IDs need to be known in advance.
#
# Enable debug logging (shows all requests and responses):
#   JIRA_DEBUG=1 bundle exec ruby examples/epic_workflow.rb
#
# Basic auth:
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_EMAIL=you@example.com \
#   JIRA_API_TOKEN=your-api-token \
#   bundle exec ruby examples/epic_workflow.rb
#
# OAuth2 with pre-fetched access token:
#   JIRA_AUTH_TYPE=oauth2 \
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_CLOUD_ID=your-cloud-id \
#   JIRA_OAUTH_ACCESS_TOKEN=your-access-token \
#   bundle exec ruby examples/epic_workflow.rb

require "bundler/setup"
require "logger"
require_relative "../lib/jira"
require "pp"

AUTH_TYPE = ENV.fetch("JIRA_AUTH_TYPE", "basic").to_sym
ENDPOINT  = ENV.fetch("JIRA_ENDPOINT")

Jira.configure do |config|
  config.endpoint  = ENDPOINT
  config.auth_type = AUTH_TYPE

  case AUTH_TYPE
  when :basic
    config.email     = ENV.fetch("JIRA_EMAIL")
    config.api_token = ENV.fetch("JIRA_API_TOKEN")
  when :oauth2
    config.cloud_id             = ENV.fetch("JIRA_CLOUD_ID")
    config.oauth_access_token   = ENV.fetch("JIRA_OAUTH_ACCESS_TOKEN", nil)
    config.oauth_client_id      = ENV.fetch("JIRA_OAUTH_CLIENT_ID", nil)
    config.oauth_client_secret  = ENV.fetch("JIRA_OAUTH_CLIENT_SECRET", nil)
    config.oauth_refresh_token  = ENV.fetch("JIRA_OAUTH_REFRESH_TOKEN", nil)
    config.oauth_grant_type     = ENV.fetch("JIRA_OAUTH_GRANT_TYPE", nil)
    config.oauth_token_endpoint = ENV.fetch(
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

# ── Discover epics via board ───────────────────────────────────────────────────

section "Agile API - find first board"
board = Jira.boards(maxResults: 1).first
puts "Using board: [#{board[:id]}] #{board[:name]}"

section "Agile API - epics on board"
epics = Jira.board_epics(board[:id], maxResults: 10)
puts "total epics: #{epics.total}"
epics.each { |e| puts "  [#{e[:id]}] #{e[:name]} (done: #{e[:done]})" }

# ── Epic operations ────────────────────────────────────────────────────────────

first_epic = epics.first
if first_epic
  section "Agile API - get epic #{first_epic[:id]}"
  epic = Jira.epic(first_epic[:id])
  puts "name: #{epic[:name]}"
  puts "summary: #{epic[:summary]}"
  puts "done: #{epic[:done]}"

  section "Agile API - issues in epic '#{epic[:name]}'"
  issues = Jira.epic_issues(epic[:id], maxResults: 10)
  puts "total: #{issues.total}"
  issues.each { |i| puts "  #{i[:key]}" }
else
  puts "No epics found on this board."
end

# ── Issues without epic ────────────────────────────────────────────────────────

section "Agile API - issues without any epic"
no_epic = Jira.issues_without_epic(maxResults: 10)
puts "total: #{no_epic.total}"
no_epic.each { |i| puts "  #{i[:key]}" }

# ── Agile issue fields ─────────────────────────────────────────────────────────

issue_key = ENV.fetch("JIRA_ISSUE_KEY", nil)
if issue_key
  section "Agile API - agile fields for #{issue_key}"
  ai = Jira.agile_issue(issue_key)
  puts "key: #{ai[:key]}"
  puts "sprint: #{ai[:fields][:sprint]&.dig(:name) || "none"}"
  puts "epic: #{ai[:fields][:epic]&.dig(:name) || "none"}"
  puts "flagged: #{ai[:fields][:flagged]}"

  section "Agile API - estimation for #{issue_key}"
  est = Jira.issue_estimation(issue_key)
  puts "field: #{est[:fieldId]}, value: #{est[:value]}"
end
