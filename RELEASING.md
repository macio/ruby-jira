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
  VERSION = "0.1.0"
end
```

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

# 2. Bump the version in lib/jira/version.rb
#    Follow Semantic Versioning (see below):
#      bug fix only       → patch: 0.1.0 → 0.1.1
#      new feature        → minor: 0.1.0 → 0.2.0
#      breaking API change → major: 0.1.0 → 1.0.0
#
#    Edit the file:
#      VERSION = "0.2.0"

# 3. Preview what the changelog will look like (does not write anything)
git cliff --tag v0.2.0

# 4. Generate CHANGELOG.md with the new release section prepended
git cliff --tag v0.2.0 --output CHANGELOG.md

# 5. Commit both files together
git add lib/jira/version.rb CHANGELOG.md
git commit -m "chore: release v0.2.0"

# 6. Create a version tag and push - the tag triggers the release workflow
git tag v0.2.0
git push origin main --follow-tags
```

Once the tag is pushed, the GitHub Actions release workflow (`.github/workflows/release.yml`) automatically:
1. Runs the full test suite
2. Regenerates CHANGELOG.md from git history
3. Builds the `.gem` file (`gem build ruby-jira.gemspec`)
4. Publishes to RubyGems.org (`gem push`) using the `RUBYGEMS_API_KEY` secret
5. Creates a GitHub Release with the `.gem` file attached

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **patch** `x.y.Z` - backwards-compatible bug fixes
- **minor** `x.Y.0` - new backwards-compatible functionality
- **major** `X.0.0` - incompatible API changes
