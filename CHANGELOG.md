# CHANGELOG

All notable changes to `fizztool` are documented in this file.

This changelog's format is based on [Keep a Changelog][01] and this project adheres to
[Semantic Versioning][02].

For releases before `1.0.0`, this project uses the following convention:

- While the major version is `0`, the code is considered unstable.
- The minor version is incremented when a backwards-incompatible change is introduced.
- The patch version is incremented when a backwards-compatible change or bug fix is introduced.

## Unreleased

### Changed

- Replaced using the root command with using subcommands. You can't call `fizztool --key fizz` and
  get a valid result anymore. You need to use `fizztool get --key fizz` instead.

### Added

- Added the new `get` command to retrieve the mocked data object. The functionality previously
  attached to the root command is now implemented in the `get` command instead. For more
  information, run `fizztool help get` in the terminal.
- Added the new `version` command to return accurate version information for `fizztool`. By
  default, it returns a JSON object with extended version information. You can use the `--one-line`
  flag to emit a shorter string that only includes the application name and version. For more
  information, run `fizztool help version` in the terminal.
- Added the new `completion` command to enable shell completions. For more information, run
  `fizztool help completion` in the terminal.
- Added the new `help` command and `--help` flag on all commands, including the root command. Now
  you can get contextual help instead of relying only on the root command's help output.
- Added colorization to the emitted JSON, making it easier to read in the terminal.

### Fixed

- Corrected the copyright header to specify `2023` instead of `2021` as the copyright date.
- Corrected the version information to accurately return the version instead of always returning
  as `v1.0.0`.

## v0.1.0 - 2023-04-11

Relevant Links
: [GitHub Release][v0.1.0]

### Added

- Initial implementation

<!-- Reference Links -->
[01]: https://keepachangelog.com/en/1.0.0/
[02]: https://semver.org/spec/v2.0.0.html
<!-- Release Links -->
[v0.1.0]: https://github.com/michaeltlombardi/fizztool/releases/tag/v0.1.0
