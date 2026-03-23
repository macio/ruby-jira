# frozen_string_literal: true

# Demonstrates using the Jira Software Cloud REST API (agile) to work with boards.
# No board ID needs to be known in advance - the script discovers boards dynamically.
#
# Enable debug logging (shows all requests and responses):
#   JIRA_DEBUG=1 bundle exec ruby examples/board_workflow.rb
#
# Basic auth:
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_EMAIL=you@example.com \
#   JIRA_API_TOKEN=your-api-token \
#   bundle exec ruby examples/board_workflow.rb
#
# Filter by board name (optional):
#   JIRA_BOARD_NAME="My Scrum Board" bundle exec ruby examples/board_workflow.rb
#
# OAuth2 with pre-fetched access token:
#   JIRA_AUTH_TYPE=oauth2 \
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_CLOUD_ID=your-cloud-id \
#   JIRA_OAUTH_ACCESS_TOKEN=your-access-token \
#   bundle exec ruby examples/board_workflow.rb

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

# ── Discover boards ────────────────────────────────────────────────────────────

section "Agile API - list boards"
boards_page = Jira.boards(maxResults: 10)
puts "total boards: #{boards_page.total}"
boards_page.each { |b| puts "  [#{b[:id]}] #{b[:name]} (#{b[:type]})" }

# Pick board by name or fall back to the first one
board_name = ENV["JIRA_BOARD_NAME"]
board = if board_name
          all = boards_page.auto_paginate
          all.find { |b| b[:name] == board_name } || raise("Board '#{board_name}' not found")
        else
          boards_page.first
        end

puts "\nUsing board: [#{board[:id]}] #{board[:name]}"

# ── Board details ──────────────────────────────────────────────────────────────

section "Agile API - board configuration"
config = Jira.board_configuration(board[:id])
puts "name: #{config[:name]}"
puts "columns: #{config[:columnConfig][:columns].map { |c| c[:name] }.join(', ')}"

section "Agile API - board features"
features = Jira.board_features(board[:id])
features[:features].each { |f| puts "  #{f[:boardFeature]}: #{f[:state]}" }

# ── Sprints ────────────────────────────────────────────────────────────────────

section "Agile API - board sprints (active + future)"
sprints = Jira.board_sprints(board[:id], state: "active,future", maxResults: 5)
puts "total: #{sprints.total}"
sprints.each { |s| puts "  [#{s[:id]}] #{s[:name]} - #{s[:state]}" }

active_sprint = sprints.find { |s| s[:state] == "active" }

if active_sprint
  section "Agile API - issues in active sprint '#{active_sprint[:name]}'"
  issues = Jira.board_sprint_issues(board[:id], active_sprint[:id], maxResults: 10)
  puts "total: #{issues.total}, showing: #{issues.size}"
  issues.each { |i| puts "  #{i[:key]}" }
end

# ── Backlog ────────────────────────────────────────────────────────────────────

section "Agile API - board backlog (first 10 issues)"
backlog = Jira.board_backlog(board[:id], maxResults: 10)
puts "total in backlog: #{backlog.total}"
backlog.each { |i| puts "  #{i[:key]}" }

# ── Epics ──────────────────────────────────────────────────────────────────────

section "Agile API - board epics"
epics = Jira.board_epics(board[:id], maxResults: 5)
puts "total epics: #{epics.total}"
epics.each { |e| puts "  [#{e[:id]}] #{e[:name]} (done: #{e[:done]})" }

# ── Projects ───────────────────────────────────────────────────────────────────

section "Agile API - board projects"
projects = Jira.board_projects(board[:id])
puts "total projects: #{projects.total}"
projects.each { |p| puts "  #{p[:key]}: #{p[:name]}" }

# ── Quick filters ──────────────────────────────────────────────────────────────

section "Agile API - board quick filters"
quick_filters = Jira.board_quick_filters(board[:id])
puts "total quick filters: #{quick_filters.total}"
quick_filters.each { |qf| puts "  [#{qf[:id]}] #{qf[:name]}: #{qf[:jql]}" }

# ── Versions ───────────────────────────────────────────────────────────────────

section "Agile API - board versions"
versions = Jira.board_versions(board[:id], maxResults: 5)
puts "total versions: #{versions.total}"
versions.each { |v| puts "  [#{v[:id]}] #{v[:name]} (released: #{v[:released]})" }
