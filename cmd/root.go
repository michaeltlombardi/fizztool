/*
Copyright © 2023 Mikey Lombardi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package cmd

import (
	"fmt"
	"os"
	"regexp"
	"runtime"
	"strings"
	"time"

	"github.com/mattn/go-colorable"
	json "github.com/neilotoole/jsoncolor"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

// Build-time variables
var (
	// The version of the app - usually the tagged version
	version = "dev"
	// The most recent commit for the build
	commit = "none"
	// The date the app was built
	date = "unknown"
)

// Retrieved as global flag for the configuration file path
var configurationFile string

// Retrieved as a flag for the `get` command
var key string

// Retrieved as a on-off flag for the `version` command
var versionOneLine bool

// The project copyright is a constant
const copyright = "(c) 2023 Tailspin Toys, Ltd."

// Used to pretty-print the JSON output with colors and indentation
var json_encoder *json.Encoder

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "fizztool",
	Short: "A small app for emitting output for test scenarios.",
	Long: `fizztool is a small application that emits output for test scenarios.

When you use the 'get' command, fizztool:

- Writes informational messages, such as banner text, progress, etc. to stderr
- Writes error messages to stderr
  - Error messages should be easily distinguished from informational messages
    and banner text
- Writes successful output to stdout
  - Success output should be a JSON object containing simple key-value pairs
`,
	SilenceUsage: true,
}

// Defines the `get` subcommand for inspecting the data store. It's just
// a mockup, returning a valid JSON blob when the key is `fizz` and otherwise
// returning an error.
var getCmd = &cobra.Command{
	Use:   "get",
	Short: "Retrieve a key from the data store.",
	Long: `Retrieve a key from the data store by name.

When you use this command, it always emits a license header with the name of
the application, its version, and the copyright notice to stderr.

If you pass the '--key' flag with 'fizz' as the value, it emits a JSON blob to
stdout.

If you pass any other value for '--key', it emits an error message reporting
that the key is invalid to stderr.

You can only retrieve one key at a time.
`,
	RunE: func(cmd *cobra.Command, args []string) error {
		// If no key specified, emit help and short-circuit
		if key == "" {
			cmd.Help()
			return nil
		}

		// Always emit the license to stderr
		cmd.PrintErrln(getFormattedNotice(version))

		// return JSON output for valid key "fizz" and emit error for others.
		if key == "fizz" {
			validResult := map[string]interface{}{
				"fizz": "buzz",
			}
			json_encoder.Encode(validResult)
		} else {
			message := fmt.Errorf("key not found: %s", key)
			return message
		}

		return nil
	},
}

// The version command, used for retrieving the version info as a JSON blob.
// with the `--one-line` flag, it emits the short info (name, version) instead.
var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Display the extended version information for fizztool.",
	Long: `Display the extended version information for fizztool.

By default, this command emits a JSON blob to stdout that includes:

- The application name.
- The version.
- The commit SHA this version was built on.
- The date this version was built.
- The URL to this version's release notes.

You can use the '--one-line' flag to emit a shorter string output,
which only includes the name and version separated by a dash wrapped in
spaces.`,
	Run: func(cmd *cobra.Command, args []string) {
		info := getVersionInfo(version, date, commit)
		if versionOneLine {
			message := fmt.Sprintf("%s - v%s", info.Name, info.Version)
			cmd.Println(message)
		} else {
			json_encoder.Encode(info)
		}
	},
}

// Execute adds all child commands to the root command and sets flags
// appropriately. This is called by main.main(). It only needs to happen once
// to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

// Initializes the commands. This handles all of the setup.
func init() {
	cobra.OnInitialize(initializeConfig, initializeJsonEncoder)

	// Ensure all commands take a config file flag
	rootCmd.PersistentFlags().StringVar(
		&configurationFile,
		"config",
		"",
		"config file (default is $HOME/.fizztool.yaml)",
	)

	// Ensure output is to stdout
	rootCmd.SetOut(rootCmd.OutOrStdout())

	// Add the getter child command
	getCmd.Flags().StringVarP(&key, "key", "k", "", "the key to fizz")
	viper.BindPFlag("key", getCmd.Flags().Lookup("key"))
	rootCmd.AddCommand(getCmd)

	versionCmd.Flags().BoolVar(
		&versionOneLine,
		"one-line",
		false,
		"Return short version on one line",
	)

	// Add the version child command
	rootCmd.AddCommand(versionCmd)
}

// initializeConfig reads in config file and ENV variables if set.
func initializeConfig() {
	if configurationFile != "" {
		// Use config file from the flag.
		viper.SetConfigFile(configurationFile)
	} else {
		// Find home directory.
		home, err := os.UserHomeDir()
		cobra.CheckErr(err)

		// Search config in home directory with name ".fizztool" (without extension).
		viper.AddConfigPath(home)
		viper.SetConfigType("yaml")
		viper.SetConfigName(".fizztool")
	}

	viper.AutomaticEnv() // read in environment variables that match

	// If a config file is found, read it in.
	if err := viper.ReadInConfig(); err == nil {
		fmt.Fprintln(os.Stderr, "Using config file:", viper.ConfigFileUsed())
	}
}

// The encoder needs to be initialized before use. This adds the colors and
// indents to the encoder.
func initializeJsonEncoder() {
	if json.IsColorTerminal(os.Stdout) {
		out := colorable.NewColorable(os.Stdout)
		json_encoder = json.NewEncoder(out)

		// Use default colors, similar to jq
		json_colors := json.DefaultColors()
		json_encoder.SetColors(json_colors)
	} else {
		// Can't use colors
		json_encoder = json.NewEncoder(os.Stdout)
	}
	json_encoder.SetIndent("", "  ")
}

// Holds the version information for the application.
type VersionInfo struct {
	// The application's name - on windows, it ends in '.exe'
	Name string `json:"name"`
	// The application's version without the 'v' prefix
	Version string `json:"version"`
	// The commit SHA the application was built on
	Commit string `json:"commit_sha"`
	// The date the application was built on
	Date string `json:"build_date"`
	// A link to the release notes for this version of the application
	ReleaseNotesUrl string `json:"release_notes_url"`
}

// Munges the build information to return a usable (and encodable) struct.
func getVersionInfo(version, buildDate string, commit string) VersionInfo {
	version = strings.TrimSpace(strings.TrimPrefix(version, "v"))

	var formattedDate string
	if buildDate != "" {
		t, _ := time.Parse(time.RFC3339, buildDate)
		formattedDate = t.Format("2006-01-02")
	}

	if commit != "" && len(commit) > 7 {
		length := len(commit) - 7
		commit = strings.TrimSpace(commit[:len(commit)-length])
	}

	return VersionInfo{
		Name:            getCommandName(),
		Version:         version,
		Commit:          commit,
		Date:            formattedDate,
		ReleaseNotesUrl: getReleaseNotesURL(version),
	}
}

// Returns the command name; on windows, returns it with `.exe` appended.
func getCommandName() string {
	commandName := "fizztool"

	if runtime.GOOS == "windows" {
		commandName = fmt.Sprintf("%s.exe", commandName)
	}

	return commandName
}

// Return the notice header, like "fizztool v1.0.0 (c) Tailspin Toys 2023"
func getFormattedNotice(version string) string {
	commandName := "fizztool"
	if runtime.GOOS == "windows" {
		commandName = fmt.Sprintf("%s.exe", commandName)
	}

	notice := fmt.Sprintf("%s v%s %s", commandName, version, copyright)

	return notice
}

// Retrieves the release notes for fizztool at this version.
func getReleaseNotesURL(version string) string {
	base_url := "https://github.com/michaeltlombardi/fizztool"
	r := regexp.MustCompile(`^v?\d+\.\d+\.\d+(-[\w.]+)?$`)

	if !r.MatchString(version) {
		return fmt.Sprintf("%s/releases/latest", base_url)
	}

	url := fmt.Sprintf(
		"%s/releases/tag/v%s",
		base_url,
		strings.TrimPrefix(version, "v"),
	)
	return url
}
