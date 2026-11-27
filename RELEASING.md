# Releasing

## One-time setup

**Install git-cliff locally:**
```bash
brew install git-cliff
```

**Add RubyGems API key to GitHub Secrets:**
1. Go to https://rubygems.org/profile/api_keys and create a key with `push` scope
2. **Important:** set MFA level to **`UI and gem signin`** (not `UI and API`) - otherwise CI will fail asking for an OTP code
3. In your GitHub repository: Settings → Secrets and variables → Actions → New secret
4. Name: `RUBYGEMS_API_KEY`, value: the key from step 1

## Commit convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/). git-cliff uses commit messages to generate the changelog automatically.

| Prefix                   | Changelog section |
| ------------------------ | ----------------- |
| `feat:`                  | Added             |
| `fix:`                   | Fixed             |
| `perf:`                  | Performance       |
| `refactor:`              | Changed           |
| `docs:`                  | Documentation     |
| `test:`, `chore:`, `ci:` | omitted           |

Breaking changes: add `!` after the prefix, e.g. `feat!: drop Ruby 3.2 support`.

## How versioning works

The gem version is defined in exactly one place:

```ruby
# lib/jira/version.rb
module Jira
  VERSION = "0.5.0"
end
```

`Gemfile.lock` also records the gem's own version (`ruby-jira (x.y.z)` under `PATH`). Running `bundle exec` after a bump updates it, so it must be committed with the release.

`ruby-jira.gemspec` reads it automatically:

```ruby
require_relative "lib/jira/version"
spec.version = Jira::VERSION
```

You never edit the version in the gemspec directly - only in `lib/jira/version.rb`.

## Releasing a new version

```bash
# 1. Make sure you are on main and the working tree is clean
git checkout main && git pull
git status  # must be clean

# 1a. Run the checks locally - the release workflow runs them too, but a local run is faster to fix
bundle exec rspec
bundle exec rubocop

# 2. Bump the version in lib/jira/version.rb
#    Follow Semantic Versioning (see below):
#      bug fix only        → patch: 0.1.0 → 0.1.1
#      new feature         → minor: 0.1.0 → 0.2.0
#      breaking API change → major: 0.1.0 → 1.0.0
#
#    Edit the file:
#      VERSION = "0.2.0"

# 3. Preview what the changelog will look like (does not write anything)
git cliff --tag v0.2.0

# 4. Generate CHANGELOG.md with the new release section prepended
git cliff --tag v0.2.0 --output CHANGELOG.md

# 5. Commit the release files together (Gemfile.lock changes with the version bump)
git add lib/jira/version.rb CHANGELOG.md Gemfile.lock
git commit -m "chore: release v0.2.0"

# 6. Create an annotated version tag and push the commit and the tag - the tag triggers the release workflow
git tag -a v0.2.0 -m "v0.2.0"
git push origin main
git push origin v0.2.0
```

Use an annotated tag (`git tag -a`) and push it explicitly. `git push --follow-tags` only sends annotated tags, so a lightweight `git tag v0.2.0` is silently skipped and no release runs.

Once the tag is pushed, the GitHub Actions release workflow (`.github/workflows/release.yml`) automatically:
1. Runs the full test suite
2. Regenerates CHANGELOG.md from git history
3. Builds the `.gem` file (`gem build ruby-jira.gemspec`)
4. Publishes to RubyGems.org (`gem push`) using the `RUBYGEMS_API_KEY` secret
5. Creates a GitHub Release with the `.gem` file attached

## Verifying a release

Check each step in this order. Do not treat the release as done until all three pass.

1. **Workflow run.** Look for the run triggered by the tag (`event: push`, `headBranch: vX.Y.Z`):
   ```bash
   gh run list --workflow release.yml --limit 3
   gh run view <run-id> --json conclusion,status,jobs --jq '{conclusion, status, jobs: [.jobs[] | {name, conclusion}]}'
   ```
   Wait for `status: completed` and `conclusion: success`. To block until the run ends, use `gh run watch <run-id> --exit-status`.
2. **GitHub release and gem asset.**
   ```bash
   gh release view vX.Y.Z --json tagName,name,assets --jq '{tagName, name, assets: [.assets[].name]}'
   ```
   The assets must include `ruby-jira-X.Y.Z.gem`.
3. **RubyGems.** The latest published version must equal the new version:
   ```bash
   curl -s https://rubygems.org/api/v1/versions/ruby-jira/latest.json
   ```
   The index can lag a few minutes behind a successful push. If you see the previous version right after the workflow succeeds, retry after a short wait before assuming a failure.

Optional, from a clean shell: `gem install ruby-jira -v X.Y.Z` confirms the gem installs.

## Pitfalls

- **Squash merges.** A squash-merged PR is not an ancestor of `main`, so `git branch --merged main` does not list its branch. Check the PR state instead (`gh pr view <n> --json state,mergedAt`), then delete the branch with `git branch -D`. Squashing also collapses the PR's commits into one changelog line, so the changelog shows a single entry per PR.
- **Lightweight tags** are skipped by `--follow-tags`; see step 6.
- **Commits on main.** Do the work on a feature branch and open a PR. Only the release commit goes straight to `main`, and only after the PR has merged.
- **Manual smoke tests against Jira.** The test suite uses WebMock and never calls Jira. For checks against a real instance, keep credentials in a local `.env` (`JIRA_ENDPOINT`, `JIRA_EMAIL`, `JIRA_API_TOKEN`). `.env` is git-ignored. Write tests need a project where the test account has the required permissions (for example "Delete Issues" to remove test issues).

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **patch** `x.y.Z` - backwards-compatible bug fixes
- **minor** `x.Y.0` - new backwards-compatible functionality
- **major** `X.0.0` - incompatible API changes
