# ruby-jira

Ruby client for the [Jira Cloud REST API v3](https://developer.atlassian.com/cloud/jira/platform/rest/v3/) and the [Jira Software Cloud REST API](https://developer.atlassian.com/cloud/jira/software/rest/intro/) (agile — sprints, boards).

The client structure follows [NARKOZ/gitlab](https://github.com/NARKOZ/gitlab), a Ruby wrapper for the GitLab API.

## Requirements

Ruby **3.3** or newer. Tested on 3.3 and 3.4. Ruby 3.2 and older are not supported (EOL).

## Installation

Add to your Gemfile:

```ruby
gem "ruby-jira"
```

## Authentication

Two auth methods are supported: **Basic** (email + API token) and **OAuth 2.0**.

### Basic auth

```ruby
Jira.configure do |config|
  config.endpoint  = "https://your-domain.atlassian.net"
  config.auth_type = :basic
  config.email     = "you@example.com"
  config.api_token = "your-api-token"
end
```

Or via environment variables:

```
JIRA_ENDPOINT=https://your-domain.atlassian.net
JIRA_EMAIL=you@example.com
JIRA_API_TOKEN=your-api-token
```

### OAuth 2.0 - pre-fetched access token

```ruby
Jira.configure do |config|
  config.endpoint           = "https://your-domain.atlassian.net"
  config.auth_type          = :oauth2
  config.cloud_id           = "your-cloud-id"
  config.oauth_access_token = "your-access-token"
end
```

### OAuth 2.0 - automatic token refresh (`refresh_token` grant)

```ruby
Jira.configure do |config|
  config.endpoint              = "https://your-domain.atlassian.net"
  config.auth_type             = :oauth2
  config.cloud_id              = "your-cloud-id"
  config.oauth_grant_type      = "refresh_token"
  config.oauth_client_id       = "your-client-id"
  config.oauth_client_secret   = "your-client-secret"
  config.oauth_refresh_token   = "your-refresh-token"
end
```

### OAuth 2.0 - service account (`client_credentials` grant)

```ruby
Jira.configure do |config|
  config.endpoint            = "https://your-domain.atlassian.net"
  config.auth_type           = :oauth2
  config.cloud_id            = "your-cloud-id"
  config.oauth_grant_type    = "client_credentials"
  config.oauth_client_id     = "your-client-id"
  config.oauth_client_secret = "your-client-secret"
end
```

## Usage

### Client

Create a one-off client or use the global `Jira` facade:

```ruby
client = Jira.client   # uses global configuration
# or
client = Jira::Client.new(endpoint: "...", email: "...", api_token: "...")
```

All methods are also available directly on the `Jira` module:

```ruby
Jira.projects
Jira.issue("TEST-1")
```

### Response objects

All responses are returned as `Jira::ObjectifiedHash` instances, supporting both dot-notation and bracket access:

```ruby
issue = Jira.issue("TEST-1")
issue.key           # => "TEST-1"
issue[:key]         # => "TEST-1"
issue.fields.summary
issue.dig(:fields, :summary)
issue.to_h          # => original Hash
```

### Projects

```ruby
# Search projects (offset-paginated)
projects = Jira.projects(status: "live", maxResults: 50)
projects.total        # => 42
projects.next_page?   # => true
projects.map(&:key)   # => ["TEST", "DEMO", ...]

# Auto-paginate all projects
all = projects.auto_paginate
all = projects.paginate_with_limit(100)

# Get a single project
project = Jira.project("TEST")
project.name
project.lead.displayName

# Archive a project
Jira.archive_project("TEST")
```

### Issues

```ruby
# Get a single issue
issue = Jira.issue("TEST-1")
issue = Jira.issue("TEST-1", expand: "names,renderedFields")

# Create an issue
issue = Jira.create_issue({
  fields: {
    project:   { key: "TEST" },
    summary:   "Something is broken",
    issuetype: { id: "10001" }
  }
})

# Update an issue
Jira.edit_issue("TEST-1", { fields: { summary: "Updated summary" } })
Jira.edit_issue("TEST-1", { fields: { summary: "Silent update" } }, notifyUsers: false)
```

### Permission schemes

```ruby
Jira.permission_scheme("TEST")
Jira.issue_security_level_scheme("TEST")
Jira.assign_permission_scheme("TEST", scheme_id: 101)
```

### Epics (Jira Software Cloud API)

```ruby
# Get a single epic
epic = Jira.epic(37)
epic.name     # => "epic 1"
epic.summary  # => "epic 1 summary"
epic.done     # => false

# Partially update an epic
Jira.update_epic(37, { name: "New name", done: true })

# Issues in an epic (offset-paginated)
issues = Jira.epic_issues(37, maxResults: 50)
issues.total
issues.auto_paginate

# Issues with no epic assigned
Jira.issues_without_epic(jql: "project = TEST")

# Move issues to an epic / remove from epic
Jira.move_issues_to_epic(37, issues: ["TEST-1", "TEST-2"])
Jira.unassign_issues_from_epic(issues: ["TEST-3"])

# Rank an epic relative to another
Jira.rank_epic(37, { rankBeforeEpic: 42 })
```

### Agile Issues (Jira Software Cloud API)

```ruby
# Get an issue with agile fields (sprint, epic, flagged)
issue = Jira.agile_issue("TEST-1")
issue.key                    # => "TEST-1"
issue.fields.sprint.name     # => "sprint 2"
issue.fields.epic.name       # => "epic 1"
issue.fields.flagged         # => true

# Estimation
est = Jira.issue_estimation("TEST-1", boardId: 84)
est[:fieldId]   # => "customfield_12532"
est[:value]     # => "8.0"

Jira.update_issue_estimation("TEST-1", { value: "13.0" }, boardId: 84)

# Rank issues relative to another
Jira.rank_issues({ issues: ["TEST-1", "TEST-2"], rankBeforeIssue: "TEST-3" })
```

### Boards (Jira Software Cloud API)

Board methods call the Jira Software Cloud REST API (`/rest/agile/1.0`). No extra configuration is needed.

```ruby
# List all boards (offset-paginated)
boards = Jira.boards(type: "scrum", maxResults: 50)
boards.total
boards.first[:name]   # => "scrum board"
boards.auto_paginate

# Boards for a filter
Jira.boards_for_filter(1001)

# Get / create / delete a board
board = Jira.board(84)
board.name      # => "scrum board"
board.type      # => "scrum"
Jira.create_board({ name: "New Board", type: "scrum", filterId: 1001 })
Jira.delete_board(84)

# Board configuration
config = Jira.board_configuration(84)
config[:columnConfig][:columns].map { |c| c[:name] }   # => ["To Do", "In Progress", "Done"]

# Features (enable/disable board panels)
Jira.board_features(84)
Jira.toggle_board_feature(84, { feature: "BACKLOG", state: "ENABLED" })

# Backlog and issues
Jira.board_backlog(84, maxResults: 50)
Jira.board_issues(84, jql: "assignee = currentUser()")
Jira.move_issues_to_board(84, issues: ["TEST-1", "TEST-2"])

# Epics
Jira.board_epics(84, done: false)
Jira.board_issues_without_epic(84)
Jira.board_epic_issues(84, 37)

# Sprints
sprints = Jira.board_sprints(84, state: "active")
Jira.board_sprint_issues(84, 37)

# Projects and versions
Jira.board_projects(84)
Jira.board_projects_full(84)
Jira.board_versions(84, released: false)

# Quick filters
Jira.board_quick_filters(84)
Jira.board_quick_filter(84, 1)

# Reports
Jira.board_reports(84)

# Board properties
Jira.board_property_keys(84)
Jira.board_property(84, "my.key")
Jira.set_board_property(84, "my.key", { foo: "bar" })
Jira.delete_board_property(84, "my.key")
```

### Sprints (Jira Software Cloud API)

Sprint methods call the Jira Software Cloud REST API (`/rest/agile/1.0`). No extra configuration is needed.

```ruby
# Get a sprint
sprint = Jira.sprint(37)
sprint.name    # => "sprint 1"
sprint.state   # => "future"

# Create / update / delete
Jira.create_sprint({ name: "Sprint 5", originBoardId: 5, goal: "ship it" })
Jira.update_sprint(37, { name: "Sprint 5 — revised" })   # partial update (POST)
Jira.replace_sprint(37, { name: "Sprint 5", originBoardId: 5, state: "active" })  # full update (PUT)
Jira.delete_sprint(37)

# Issues in a sprint (offset-paginated)
issues = Jira.sprint_issues(37, maxResults: 50)
issues.total
issues.auto_paginate
issues.map { |i| i[:key] }

# Move issues into a sprint
Jira.move_issues_to_sprint(37, issues: ["TEST-1", "TEST-2"])

# Swap sprint position with another sprint
Jira.swap_sprint(37, sprint_to_swap_with: 42)

# Sprint properties
Jira.sprint_property_keys(37)
Jira.sprint_property(37, "my.key")
Jira.set_sprint_property(37, "my.key", { foo: "bar" })
Jira.delete_sprint_property(37, "my.key")
```

### Users

```ruby
Jira.myself[:displayName]
Jira.user("5b10ac8d82e05b22cc7d4ef5")
Jira.user_search("mia")                       # Array
Jira.user_assignable_search(project: "TEST")  # Array
```

### Fields and metadata

```ruby
Jira.fields                        # system and custom fields
Jira.field_search(type: "custom")  # paginated
Jira.issue_types
Jira.priorities
Jira.statuses
Jira.resolutions
Jira.labels(maxResults: 100)       # paginated; values are strings
```

Create-screen metadata shows which fields are required for a new issue:

```ruby
# One entry per issue type of the project. Items are the createMetaIssueType entries.
Jira.create_metadata("TEST").each { |type| puts type[:name] }

# Field definitions for one issue type
Jira.create_metadata_for_issue_type("TEST", 10001).each { |field| puts field[:fieldId] }
```

### Attachments

```ruby
attachments = Jira.add_attachment("TEST-1", "/path/to/report.pdf")  # Array of attachment hashes
id = attachments.first[:id]

Jira.attachment(id)[:mimeType]
File.binwrite("report.pdf", Jira.attachment_content(id))  # raw bytes, not parsed
Jira.delete_attachment(id)
```

Uploading requires the "Create attachments" project permission.

### Issue links

```ruby
Jira.issue_link_types[:issueLinkTypes].map { |t| t[:name] }

Jira.create_issue_link(
  type: { name: "Blocks" },
  inwardIssue: { key: "TEST-2" },
  outwardIssue: { key: "TEST-1" }
)

# The link ID is listed under the issue's fields.issuelinks
link_id = Jira.issue("TEST-1", fields: "issuelinks").dig(:fields, :issuelinks, 0, :id)
Jira.issue_link(link_id)
Jira.delete_issue_link(link_id)
```

`create_issue_link` returns an empty body with HTTP 201.

### Atlassian Document Format (ADF)

Jira v3 expects ADF for rich-text fields such as descriptions and comment bodies. `Jira::ADF.from_text` converts plain text:

- a blank line starts a new paragraph
- a single newline becomes a line break inside the paragraph

```ruby
doc = Jira::ADF.from_text("First paragraph\nsecond line\n\nSecond paragraph")

Jira.create_issue(fields: {
  project: { key: "TEST" },
  issuetype: { name: "Task" },
  summary: "Rich description",
  description: doc
})

Jira.add_comment("TEST-1", body: doc)
```

Other ADF features (marks, lists, tables) are not generated by this helper. Build those hashes by hand.

### Versions and components

```ruby
version = Jira.create_version(name: "1.0", project: "TEST")
Jira.update_version(version[:id], released: true)
Jira.project_versions("TEST")  # Array
Jira.delete_version(version[:id])

component = Jira.create_component(name: "Backend", project: "TEST")
Jira.update_component(component[:id], description: "Server-side code")
Jira.project_components("TEST")  # Array
Jira.delete_component(component[:id])
```

### Filters

```ruby
Jira.my_filters                   # Array
Jira.filter(10000)
Jira.filter_search(filterName: "bugs")  # paginated
```

### Groups and project roles

```ruby
Jira.group("jira-developers")
Jira.group_members("jira-developers", maxResults: 50)
Jira.add_user_to_group("jira-developers", "5b10ac8d82e05b22cc7d4ef5")
Jira.remove_user_from_group("jira-developers", "5b10ac8d82e05b22cc7d4ef5")

# Role name => role URL
Jira.project_roles("TEST")
# A role with its actors
Jira.project_role("TEST", 10001)
```

Changing group membership needs the matching Jira administration permissions.

### Workflows, screens and audit records

Read-only endpoints:

```ruby
Jira.workflows(maxResults: 50)  # paginated
Jira.screens(maxResults: 50)    # paginated
Jira.audit_records(from: "2026-11-01", limit: 100)[:records]  # the hash has records, total, offset, limit
```

### Bulk operations and changelogs

```ruby
# Asynchronous: the response is a task ID, not the result of the deletion
task = Jira.bulk_delete_issues(["TEST-10", "TEST-11"], send_notification: false)
task[:taskId]

# Changelog entries for specific changelog IDs (paginated; entries under histories)
Jira.issue_changelogs_by_ids("TEST-1", [10237]).first
```

`issue_changelog` (without `_by_ids`) returns the full changelog of an issue. Use the `_by_ids` variant when you already know the IDs.

### Webhooks

Jira posts webhook deliveries to an HTTP endpoint you own. `Jira::Webhook::Event.parse` turns the body into an object. Pass the raw body (a String) or an already decoded Hash:

```ruby
event = Jira::Webhook::Event.parse(request.body.read)

if event.is_a?(Jira::Webhook::Event)
  event.created?          # or event.updated?
  event.issue[:key]
  event.user[:displayName]
  event.changelog&.dig(:items)  # present for updates
else
  # Other event types are returned as the decoded Hash
end
```

The gem parses `jira:issue_created` and `jira:issue_updated`. It does not register webhooks; create them in Jira or with your own client code.

### Pagination

Jira Cloud returns different pagination shapes from different endpoints. The gem exposes all of them through the same methods: `auto_paginate`, `each_page`, and `paginate_with_limit`.

Offset-paginated responses return `Jira::PaginatedResponse` - includes `GET /project/search`, `GET /issue/{key}/comment`,
`GET /issue/{key}/worklog`, and others:

```ruby
page = Jira.projects
page.total          # total count
page.start_at       # current offset
page.max_results    # page size
page.last_page?     # isLast flag
page.next_page?
page.next_page      # fetches the next page
page.auto_paginate  # fetches all pages, returns flat Array
page.paginate_with_limit(200)
page.each_page { |p| process(p) }
```

Cursor-paginated responses (`GET /search/jql`, `POST /search/jql`) return `Jira::CursorPaginatedResponse`:

```ruby
# GET /search/jql returns minimal issue payload by default (id only).
# Pass fields/expand to fetch richer issue data.
results = Jira.search_issues_jql(
  jql: "project = TEST ORDER BY created DESC",
  fields: "key,summary"
)
results.next_page_token   # raw token
results.next_page?
results.next_page         # fetches next page automatically
results.auto_paginate     # fetches all pages
results.paginate_with_limit(200)
```

### Rate limiting

Since March 2, 2026, Jira Cloud applies points-based quotas to OAuth 2.0 and app traffic. API token traffic is still governed by burst limits. The retry behaviour below follows the [Jira Cloud rate limiting guide](https://developer.atlassian.com/cloud/jira/platform/rate-limiting/).

The client automatically retries `429 Too Many Requests` and `503 Service Unavailable` (when rate-limit headers are present) on idempotent requests (`GET`, `PUT`, `DELETE`).

**Supported response headers** (as enforced by Jira Cloud):

| Header                  | Format             | Description                                                                    |
| ----------------------- | ------------------ | ------------------------------------------------------------------------------ |
| `Retry-After`           | integer seconds    | How long to wait before retrying (429 and some 503)                            |
| `X-RateLimit-Reset`     | ISO 8601 timestamp | When the rate-limit window resets (429 only)                                   |
| `X-RateLimit-Limit`     | integer            | Max request rate for the current scope                                         |
| `X-RateLimit-Remaining` | integer            | Remaining capacity in the current window                                       |
| `X-RateLimit-NearLimit` | `"true"`           | Signals < 20% capacity remains - consider throttling proactively               |
| `RateLimit-Reason`      | string             | Which limit was exceeded (`jira-burst-based`, `jira-quota-tenant-based`, etc.) |

**Retry strategy:** exponential backoff with proportional jitter (`delay × rand(0.7..1.3)`), respecting `Retry-After` and `X-RateLimit-Reset` headers. Falls back to backoff when no header is present.

Default configuration (aligned with Atlassian recommendations):

```ruby
Jira.configure do |config|
  config.ratelimit_retries    = 4     # retries after the first request (5 requests in total)
  config.ratelimit_base_delay = 2.0   # seconds, base for exponential backoff
  config.ratelimit_max_delay  = 30.0  # seconds, cap on backoff
end
```

### Logging

Pass any `Logger`-compatible object to enable debug logging. All requests, detected response types, and rate-limit retries are logged at `DEBUG` level.

```ruby
require "logger"

Jira.configure do |config|
  config.logger = Logger.new($stdout)
end
```

Sample output:

```
GET /project/search {query: {maxResults: 50}}
→ Jira::PaginatedResponse
GET /search/jql {query: {jql: "project=TEST", nextPageToken: "..."}}
→ Jira::CursorPaginatedResponse
rate limited (HTTP 429), retrying in 5.0s (3 retries left)
```

Logging is disabled by default (`config.logger = nil`).

### Proxy

```ruby
Jira.http_proxy("proxy.example.com", 8080, "user", "pass")
```

## Configuration reference

| Key                    | ENV variable                | Default                                  |
| ---------------------- | --------------------------- | ---------------------------------------- |
| `endpoint`             | `JIRA_ENDPOINT`             | —                                        |
| `auth_type`            | `JIRA_AUTH_TYPE`            | `:basic`                                 |
| `email`                | `JIRA_EMAIL`                | —                                        |
| `api_token`            | `JIRA_API_TOKEN`            | —                                        |
| `oauth_access_token`   | `JIRA_OAUTH_ACCESS_TOKEN`   | —                                        |
| `oauth_client_id`      | `JIRA_OAUTH_CLIENT_ID`      | —                                        |
| `oauth_client_secret`  | `JIRA_OAUTH_CLIENT_SECRET`  | —                                        |
| `oauth_refresh_token`  | `JIRA_OAUTH_REFRESH_TOKEN`  | —                                        |
| `oauth_grant_type`     | `JIRA_OAUTH_GRANT_TYPE`     | —                                        |
| `oauth_token_endpoint` | `JIRA_OAUTH_TOKEN_ENDPOINT` | `https://auth.atlassian.com/oauth/token` |
| `cloud_id`             | `JIRA_CLOUD_ID`             | —                                        |
| `ratelimit_retries`    | `JIRA_RATELIMIT_RETRIES`    | `4`                                      |
| `ratelimit_base_delay` | `JIRA_RATELIMIT_BASE_DELAY` | `2.0`                                    |
| `ratelimit_max_delay`  | `JIRA_RATELIMIT_MAX_DELAY`  | `30.0`                                   |
| `logger`               | —                           | `nil`                                    |

## Error handling

```ruby
rescue Jira::Error::Unauthorized    # 401
rescue Jira::Error::Forbidden       # 403
rescue Jira::Error::NotFound        # 404
rescue Jira::Error::Gone            # 410, the endpoint was removed (e.g. legacy /search)
rescue Jira::Error::TooManyRequests # 429
rescue Jira::Error::ResponseError   # any other 4xx/5xx
rescue Jira::Error::Base            # all gem errors
```

`Jira::Error::ResponseError` exposes:

```ruby
e.response_status   # HTTP status code
e.response_message  # parsed message from response body
```

## Testing

Unit specs run offline with `bundle exec rspec`. Live specs run against a Jira test instance with `bundle exec rake live`. See [TESTING.md](TESTING.md) for setup, how to test a new endpoint, and the current limitations.

## Examples

Runnable scripts are in [`examples/`](examples/):

| Script | What it shows |
| ------ | ------------- |
| `basic_usage.rb` | Projects, issues and search against a real instance |
| `pagination.rb` | Offset and cursor pagination |
| `board_workflow.rb` | Boards, sprints and backlog |
| `sprint_workflow.rb` | Sprint lifecycle |
| `epic_workflow.rb` | Epics and agile issues |
| `attachments_migrate.rb` | Copies attachments from one issue to another |
| `webhook_sync.rb` | Parses a saved webhook delivery |

Run `basic_usage.rb` with credentials from the environment:

```bash
JIRA_ENDPOINT=https://your-domain.atlassian.net \
JIRA_EMAIL=you@example.com \
JIRA_API_TOKEN=your-api-token \
JIRA_PROJECT_KEY=TEST \
bundle exec ruby examples/basic_usage.rb
```

`basic_usage.rb` lists all supported environment variables.
