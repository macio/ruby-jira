# frozen_string_literal: true

# Demonstrates unified pagination helpers across Jira pagination models:
# offset (PaginatedResponse) and cursor (CursorPaginatedResponse).
#
# Basic auth:
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_EMAIL=you@example.com \
#   JIRA_API_TOKEN=your-api-token \
#   bundle exec ruby examples/pagination.rb
#
# OAuth2 with pre-fetched access token:
#   JIRA_AUTH_TYPE=oauth2 \
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_CLOUD_ID=your-cloud-id \
#   JIRA_OAUTH_ACCESS_TOKEN=your-access-token \
#   bundle exec ruby examples/pagination.rb
#
# Enable debug logging (shows requests, response types, detected items key):
#   JIRA_DEBUG=1 bundle exec ruby examples/pagination.rb

require "bundler/setup"
require "logger"
require_relative "../lib/jira"

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

JQL = ENV.fetch("JIRA_JQL", "project=TEST ORDER BY created DESC")

# =============================================================================
# Offset pagination — Jira::PaginatedResponse
# Returned by: GET /project/search, GET /issue/{key}/comment, GET /issue/{key}/worklog, etc.
# =============================================================================

section "Offset pagination: auto_paginate with block"
count = 0
Jira.projects(maxResults: 50).auto_paginate do |project|
  puts "  #{project.key}: #{project.name}"
  count += 1
end
puts "Total yielded: #{count}"

section "Offset pagination: auto_paginate returning array"
all = Jira.projects(maxResults: 50).auto_paginate
puts "Fetched #{all.length} projects"

section "Offset pagination: each_page"
Jira.projects(maxResults: 50).each_page do |page|
  puts "  startAt=#{page.start_at}, count=#{page.length}, last=#{page.last_page?}"
end

section "Offset pagination: paginate_with_limit(3)"
Jira.projects(maxResults: 50).paginate_with_limit(3).each do |project|
  puts "  #{project.key}"
end

# =============================================================================
# Cursor pagination — Jira::CursorPaginatedResponse
# Returned by: GET /search/jql, POST /search/jql
# =============================================================================

section "Cursor pagination: auto_paginate with block"
count = 0
# GET /search/jql returns minimal issue data by default (id only).
# Pass fields: "key,summary" to include additional fields.
Jira.search_issues_jql(jql: JQL, maxResults: 20).auto_paginate do |issue|
  puts "  id=#{issue[:id]}"
  count += 1
end
puts "Total yielded: #{count}"

section "Cursor pagination: auto_paginate returning array"
all = Jira.search_issues_jql(jql: JQL, maxResults: 20).auto_paginate
puts "Fetched #{all.length} issues"

section "Cursor pagination: each_page"
Jira.search_issues_jql(jql: JQL, maxResults: 20).each_page do |page|
  puts "  token=#{page.next_page_token.inspect}, count=#{page.length}, last=#{!page.next_page?}"
end

section "Cursor pagination: paginate_with_limit(3)"
Jira.search_issues_jql(jql: JQL, maxResults: 20).paginate_with_limit(3).each do |issue|
  puts "  id=#{issue[:id]}"
end
