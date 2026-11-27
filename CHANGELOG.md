# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2026-11-27

### Added

- Add parser for Jira issue created and updated webhook deliveries (#20) ([6d55144](https://github.com/macio/ruby-jira/commit/6d55144430f56f4bcec835b612f5eed38ee1523b))
- Add read-only workflow, screen and audit record endpoints (#19) ([c131307](https://github.com/macio/ruby-jira/commit/c13130780c3818158ee36b850f4a65b429cdd116))
- Add group and project role endpoints (#18) ([48f30e6](https://github.com/macio/ruby-jira/commit/48f30e6b6f95265bfc1f6a3f8dbe8d2b6126e14e))
- Add bulk issue delete and changelog lookup by IDs (#17) ([27bc74b](https://github.com/macio/ruby-jira/commit/27bc74b40e8239de969f7306ecc2353e87ddf397))

### Documentation

- Document new endpoints in README and remove filler wording (#23) ([46c3b35](https://github.com/macio/ruby-jira/commit/46c3b3599ae811870f6e405520cdc4e855c598cb))
- Add webhook sync and attachment migration examples (#21) ([ec23d7d](https://github.com/macio/ruby-jira/commit/ec23d7d45d8a60d90b1b5fd3b50594a9ec1b1bf0))
- Add release verification, tag and squash-merge pitfalls to RELEASING (#15) ([7dc60d1](https://github.com/macio/ruby-jira/commit/7dc60d14b5185f158e6ccd3bdd90b5da5fe99b91))

### Fixed

- Make rate limit retries match ratelimit_retries; add Gone error for HTTP 410 (#16) ([fb11939](https://github.com/macio/ruby-jira/commit/fb119394bd2220224d2cf8f4e0b52eb53a4e03fa))

## [0.5.0] - 2026-11-27

### Added

- Add Users, Fields, Attachments, Issue links, Versions, Components, Filters and ADF helper (#14) ([c279fd5](https://github.com/macio/ruby-jira/commit/c279fd51fb8a4562685eb1502a474e71ca33fd61))

## [0.4.0] - 2026-11-27

### Added

- **breaking** Drop Ruby 3.2 and refresh CI and dependencies (#13) ([bbf7abb](https://github.com/macio/ruby-jira/commit/bbf7abbddac1418bc676cca76438bd754e18707c))

## [0.3.0] - 2026-11-27

### Added

- Add epic and agile issue endpoints (Jira Software Cloud API) (#12) ([3ad2c31](https://github.com/macio/ruby-jira/commit/3ad2c311abae5a54de2723cbf8827400aece3ec6))
- Add board endpoints (Jira Software Cloud API) (#11) ([e62a7cb](https://github.com/macio/ruby-jira/commit/e62a7cb7c818010a0880c256690ed679e78d70eb))
- Add Jira Software Cloud agile API - sprint endpoints (#10) ([a17893d](https://github.com/macio/ruby-jira/commit/a17893dd013547430846a9a1af51901a7ced5ea4))

## [0.2.0] - 2026-03-14

### Added

- Issue-worklogs-api (#9) ([fefa37c](https://github.com/macio/ruby-jira/commit/fefa37c48ecabaf62353015c3cc3866f6bfb251d))
- Add time tracking api (#8) ([836bc35](https://github.com/macio/ruby-jira/commit/836bc35ba53369acf683bf3c18424816b9aecf8e))
- Add project categories (#7) ([7bd8f80](https://github.com/macio/ruby-jira/commit/7bd8f8004d708ba49dd867dd4fffa083d7021886))
- Add project properties client (#6) ([db8796f](https://github.com/macio/ruby-jira/commit/db8796fcc59f34d91b5e9835730581ff9599fb5b))
- Universal pagination (#5) ([d828945](https://github.com/macio/ruby-jira/commit/d828945b69e3e384e8e43c5b788f853bdf966963))
- Issue search api (#4) ([74f22ea](https://github.com/macio/ruby-jira/commit/74f22ea5e66583f17a124b30bc0582d81d8153a0))
- Issue comments api (#3) ([d54da8d](https://github.com/macio/ruby-jira/commit/d54da8d55c749399381c896d56ec80dfd7e9a0d1))
- Issues and permission schemes api (#2) ([d57857d](https://github.com/macio/ruby-jira/commit/d57857d0c682a338212ae1d5e2e06d78926cb767))
- Projects api methods (#1) ([e410703](https://github.com/macio/ruby-jira/commit/e4107033b0229886dab39ae865de115f78d2d911))

## [0.1.0] - 2026-03-09

### Added

- Add initial ruby-jira Jira API client gem ([09c7c53](https://github.com/macio/ruby-jira/commit/09c7c5302cec9ccd079d85f0c46466f53775e9da))

[0.6.0]: https://github.com/macio/ruby-jira/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/macio/ruby-jira/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/macio/ruby-jira/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/macio/ruby-jira/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/macio/ruby-jira/compare/v0.1.0...v0.2.0

