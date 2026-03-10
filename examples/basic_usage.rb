# frozen_string_literal: true

# Run this script to exercise the gem against a real Jira Cloud instance.
#
# Enable debug logging (shows all requests, responses, rate-limit retries):
#   JIRA_DEBUG=1 bundle exec ruby examples/basic_usage.rb
#
# Basic auth:
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_EMAIL=you@example.com \
#   JIRA_API_TOKEN=your-api-token \
#   JIRA_PROJECT_KEY=TEST \
#   bundle exec ruby examples/basic_usage.rb
#
# OAuth2 with pre-fetched access token:
#   JIRA_AUTH_TYPE=oauth2 \
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_CLOUD_ID=your-cloud-id \
#   JIRA_OAUTH_ACCESS_TOKEN=your-access-token \
#   JIRA_PROJECT_KEY=TEST \
#   bundle exec ruby examples/basic_usage.rb
#
# OAuth2 with automatic token refresh (refresh_token grant):
#   JIRA_AUTH_TYPE=oauth2 \
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_CLOUD_ID=your-cloud-id \
#   JIRA_OAUTH_GRANT_TYPE=refresh_token \
#   JIRA_OAUTH_CLIENT_ID=your-client-id \
#   JIRA_OAUTH_CLIENT_SECRET=your-client-secret \
#   JIRA_OAUTH_REFRESH_TOKEN=your-refresh-token \
#   JIRA_PROJECT_KEY=TEST \
#   bundle exec ruby examples/basic_usage.rb
#
# OAuth2 for service account (client_credentials grant):
#   JIRA_AUTH_TYPE=oauth2 \
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_CLOUD_ID=your-cloud-id \
#   JIRA_OAUTH_GRANT_TYPE=client_credentials \
#   JIRA_OAUTH_CLIENT_ID=your-client-id \
#   JIRA_OAUTH_CLIENT_SECRET=your-client-secret \
#   JIRA_PROJECT_KEY=TEST \
#   bundle exec ruby examples/basic_usage.rb

require "bundler/setup"
require "logger"
require_relative "../lib/jira"
require "pp"

AUTH_TYPE   = ENV.fetch("JIRA_AUTH_TYPE", "basic").to_sym
ENDPOINT    = ENV.fetch("JIRA_ENDPOINT")
PROJECT_KEY = ENV.fetch("JIRA_PROJECT_KEY", "TEST")

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

# --- Projects ---

section "Projects search"
projects = Jira.projects(status: "live", maxResults: 5)
show projects
puts "keys: #{projects.map { |p| p[:key] }.join(", ")}"

section "Single project"
project = Jira.project(PROJECT_KEY)
show project

# --- Permission schemes ---

section "Permission scheme"
show Jira.permission_scheme(PROJECT_KEY)

section "Issue security level scheme"
show Jira.issue_security_level_scheme(PROJECT_KEY)

# --- Issues (optional) ---

issue_key = ENV["JIRA_ISSUE_KEY"].to_s
unless issue_key.empty?
  section "Single issue: #{issue_key}"
  show Jira.issue(issue_key)
end

if ENV["JIRA_CREATE_ISSUE"] == "1"
  payload = {
    fields: {
      project:   { key: PROJECT_KEY },
      summary:   ENV.fetch("JIRA_NEW_ISSUE_SUMMARY", "Issue created by ruby-jira examples/basic_usage.rb"),
      issuetype: { id: ENV.fetch("JIRA_ISSUE_TYPE_ID") }
    }
  }

  section "Create issue"
  show Jira.create_issue(payload)
end

edit_key = ENV["JIRA_EDIT_ISSUE_KEY"].to_s
unless edit_key.empty?
  section "Edit issue: #{edit_key}"
  show Jira.edit_issue(edit_key, { fields: { summary: ENV.fetch("JIRA_EDIT_SUMMARY", "Updated by basic_usage.rb") } })
end

archive_key = ENV["JIRA_ARCHIVE_PROJECT_KEY"].to_s
unless archive_key.empty?
  section "Archive project: #{archive_key}"
  show Jira.archive_project(archive_key)
end
