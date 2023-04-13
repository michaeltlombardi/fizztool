# v1.0.0 - 2023-04-14

Relevant Links:

- [GitHub Release][v1.0.0-release]
- [Addressed Issues][v1.0.0-issues]
- [Merged Pull Requests][v1.0.0-pulls]

## Changed

- Replaced using the root command with using subcommands. You can't call `fizztool --key fizz` and
  get a valid result anymore. You need to use `fizztool get --key fizz` instead.

## Added

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

<!-- Release Links -->
[v1.0.0-release]: https://github.com/michaeltlombardi/fizztool/releases/tag/v1.0.0
[v1.0.0-issues]:  https://github.com/michaeltlombardi/fizztool/issues?q=is%3Aissue+milestone%3Av1.0.0+is%3Aclosed
[v1.0.0-pulls]:   https://github.com/michaeltlombardi/fizztool/pulls?q=is%3Apr+milestone%3Av1.0.0+is%3Aclosed
