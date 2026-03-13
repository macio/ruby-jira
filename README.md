# ruby-jira

Ruby client for the [Jira Cloud REST API v3](https://developer.atlassian.com/cloud/jira/platform/rest/v3/).

> Inspired by and based on the architecture of [NARKOZ/gitlab](https://github.com/NARKOZ/gitlab) — a Ruby wrapper for the GitLab API. Many thanks for the solid foundation.

## Requirements

Ruby **3.2** or newer. Tested on 3.2, 3.3, and 3.4. Ruby 3.1 and older are not supported (EOL).

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

### Pagination

Jira Cloud uses multiple pagination shapes across endpoints. This gem unifies them with `auto_paginate`, `each_page`,
and `paginate_with_limit`.

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

> Atlassian enforces a new points-based and tiered quota rate limiting policy for Jira Cloud apps since **March 2, 2026**.
> This gem follows the current [official Jira Cloud Rate Limiting guide](https://developer.atlassian.com/cloud/jira/platform/rate-limiting/).

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
  config.ratelimit_retries    = 4     # max retry attempts
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
rescue Jira::Error::TooManyRequests # 429
rescue Jira::Error::ResponseError   # any other 4xx/5xx
rescue Jira::Error::Base            # all gem errors
```

`Jira::Error::ResponseError` exposes:

```ruby
e.response_status   # HTTP status code
e.response_message  # parsed message from response body
```

## Running the example script

```bash
JIRA_ENDPOINT=https://your-domain.atlassian.net \
JIRA_EMAIL=you@example.com \
JIRA_API_TOKEN=your-api-token \
JIRA_PROJECT_KEY=TEST \
bundle exec ruby examples/basic_usage.rb
```

See [examples/basic_usage.rb](examples/basic_usage.rb) for all supported environment variables.
