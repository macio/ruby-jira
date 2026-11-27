# Testing

The test suite has two layers.

| Layer | Files | Network | Runs |
| ----- | ----- | ------- | ---- |
| Unit | `spec/**/*_spec.rb` | None (WebMock stubs) | `rake spec`, `bundle exec rspec`, CI, release |
| Live | `spec/**/*_live_spec.rb` | Jira test instance | Only `rake live` or an explicit file path |

Unit specs check how the gem builds requests and parses responses. Live specs check that Jira accepts the gem's requests and returns what the gem expects, and they record the fixtures that unit specs use.

## Commands

```bash
# Unit specs, offline (default; this is what CI runs)
bundle exec rspec

# All live specs against the test instance
bundle exec rake live

# One live spec file
bundle exec rspec spec/jira/client/users_live_spec.rb
```

`.rspec` excludes `*_live_spec.rb` from the default run. Passing a file path explicitly still runs it, which is how `rake live` works.

## Live setup

Create a `.env` file in the repository root (it is git-ignored):

```
JIRA_ENDPOINT=https://pinokio.atlassian.net
JIRA_EMAIL=you@example.com
JIRA_API_TOKEN=your-api-token
```

Requirements, checked before the first live example runs:

- **Host allowlist.** Live specs only run against hosts listed in `Jira::Live::ALLOWED_HOSTS` (`spec/live_helper.rb`). Any other host stops the run.
- **Project.** All data is created in project `TEST` (`Jira::Live::PROJECT_KEY`).
- **Permissions.** The account needs `CREATE_ISSUES`, `EDIT_ISSUES` and `DELETE_ISSUES` in `TEST`. In a team-managed project, deleting issues requires the Administrators role. A missing permission stops the run with a message naming it.

## Writing tests for a new or changed endpoint

1. Implement the method in `lib/jira/client/<resource>.rb` with its `@url` doc link.
2. Write `spec/jira/client/<resource>_live_spec.rb`:
   - `require "live_helper"` at the top.
   - Call the method against the test instance and assert the gem's contract: return type, the keys the gem and its docs rely on, and the effect of writes (read the data back).
   - Wrap the call whose response should become a fixture in `record_fixture("<name>") { ... }`.
   - Create issues only through `Jira::Live::RunScope#create_issue` and call `cleanup!` in an `after` hook.
   - Register other data the spec creates (versions, components, filters, attachments) with `RunScope#on_cleanup`. Give named data the run prefix (`scope.prefix`) in its name.
3. Run `bundle exec rspec spec/jira/client/<resource>_live_spec.rb`. It writes:
   - `spec/fixtures/<name>.json` — the sanitized response.
   - `spec/fixtures/<name>_request.json` — the sanitized request body, for requests with a JSON body.
4. Write or update `spec/jira/client/<resource>_spec.rb` to use those fixtures:
   - Stub the response with `stub_get` / `stub_post` and the recorded fixture name.
   - For methods that build a request body, assert it against the recorded payload: `a_post(path).with(body: fixture_json("<name>_request"))`.
   - Read expected values from the fixture instead of hard-coding IDs, dates or names that change on every recording.
5. Review `git diff spec/fixtures` before committing (see below).

Edge cases that cannot be recorded (errors, `429` with `Retry-After`, multi-page pagination) keep hand-written fixtures and stubs.

## Recorded fixtures

- Every live run overwrites the fixtures it records. Changed IDs and dates are expected. A changed structure (new, renamed or missing keys) means Jira's behavior changed and the gem or its tests may need an update.
- Fixtures are sanitized before they are written (`spec/support/live/sanitizer.rb`): `emailAddress`, `accountId`, `authorAccountId`, `authorKey`, `displayName` and `remoteAddress` get fixed placeholder values, `avatarUrls` is removed, and the instance host, the site name (for example in group names such as `jira-users-<site>`), the account email and every replaced account ID are also replaced inside strings such as `self` URLs.
- Fixtures are read as UTF-8 (`load_fixture`, `fixture_json`), because recorded responses contain non-ASCII characters.
- Before committing new fixtures, check that they do not contain the real host, email, account ID or token.

## Cleanup

- `RunScope#create_issue` gives each issue the label `ruby-jira-live` and the run prefix in its summary, and tracks it.
- `RunScope#cleanup!` runs the `on_cleanup` blocks, then deletes tracked issues, and reports every failure after trying all of them.
- At the start of every live run, `RunScope.sweep_stale!` deletes data older than one hour, left behind by interrupted runs: labelled issues, and versions and components whose name starts with the run prefix. Issues are matched by label, not by summary, because Jira indexes `ruby-jira-live-<time>` as one token and a text search does not find it. Filters are not swept; an interrupted run can leave one behind.
- Live specs confirm deletion with `GET` (expecting `404`), not with JQL, because the search index can lag behind.

## Coverage

The coverage minimum (`spec/spec_helper.rb`) is enforced only when `CI` is set, which GitHub Actions does. Local partial runs, including `rake live`, do not fail on coverage. Live runs are reported under the command name `RSpec live`, so SimpleCov merges them with a unit run made within its merge timeout (10 minutes by default). CI coverage comes from unit specs only, so every method with a live spec also needs a unit spec.

## Limitations

- **Team-managed project.** `TEST` is a team-managed project. Live specs do not cover company-managed projects, where workflows, screens, components and versions can behave differently.
- **Webhooks.** Webhook deliveries are not tested live; that would need a public endpoint.
- **Local only.** Live specs do not run in CI or in the release workflow, so their results depend on someone running `rake live`.
- **Personal credentials.** Live specs use the token from `.env`. A dedicated test account limits what a leaked token can do.
