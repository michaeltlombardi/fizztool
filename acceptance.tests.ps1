param (
    [Parameter(Mandatory)]
    [System.Management.Automation.ApplicationInfo] $Application
)

BeforeAll {
    $HelpSynopsisPattern = '^fizztool is a small application that emits output for test scenarios.'
    $NamePattern = 'fizztool(\.exe)?'
    $VersionPattern = 'v\d+\.\d+\.\d+(-next)?'
    $CopyrightPattern = [regex]::Escape('(c) 2023 Tailspin Toys, Ltd.')
    $LicensePattern = "$NamePattern $VersionPattern $CopyrightPattern"
    $Info = @{
        Commands = @(
            @{
                Name = 'completion'
                HelpInfo = @{
                    SynopsisPattern = '^Generate the autocompletion script for fizztool for the specified shell'
                    Tests = @(
                        @{
                            Condition = 'called without parameters'
                            Arguments = @()
                        }
                        @{
                            Condition = "called with '--help'"
                            Arguments = @('--help')
                        }
                    )
                }
                FunctionalTests = @()
            }
            @{
                Name = 'get'
                HelpInfo = @{
                    SynopsisPattern = '^Retrieve a key from the data store by name'
                    Tests = @(
                        @{
                            Condition = 'called without parameters'
                            Arguments = @()
                        }
                        @{
                            Condition = "called with '--help'"
                            Arguments = @('--help')
                        }
                    )
                }
                FunctionalTests = @()
            }
            @{
                Name = 'help'
                HelpInfo = @{
                    SynopsisPattern = '^Help provides help for any command in the application'
                    Tests = @(
                        @{
                            Condition = "called with argument 'help'"
                            Arguments = @('help')
                        }
                        @{
                            Condition = "called with '--help'"
                            Arguments = @('--help')
                        }
                    )
                }
                FunctionalTests = @(
                    @{
                        Name = 'displays help for the application when called without arguments'
                        Arguments = @()
                        ExpectedExitCode = 0
                        Validation = {
                            param($Result)
                            $Result | Should -Match $HelpSynopsisPattern
                        }
                    }
                )
            }
            @{
                Name = 'version'
                HelpInfo = @{
                    SynopsisPattern = '^Display the extended version information for fizztool'
                    Tests = @(
                        @{
                            Condition = "called with '--help'"
                            Arguments = @('--help')
                        }
                    )
                }
                FunctionalTests = @(
                    @{
                        Name = 'displays extended version info as a valid json blob by default'
                        Arguments = @()
                        ExpectedExitCode = 0
                        Validation = {
                            param($Result)
                            $ObjectResult = $Result | ConvertFrom-Json
                            $ObjectResult.name | Should -Not -BeNullOrEmpty
                            $ObjectResult.version | Should -Not -BeNullOrEmpty
                            $ObjectResult.commit_sha | Should -Not -BeNullOrEmpty
                            $ObjectResult.release_notes_url | Should -Not -BeNullOrEmpty
                        }
                    }
                )
            }
        )
    }
}
  
Describe '<Application>' -Tag Acceptance {
    Context 'using the root command without parameters' {
        It 'displays help info' {
            $Result = & $Application 2>&1
            $LASTEXITCODE | Should -Be 0
            $Result | Should -Not -BeNullOrEmpty
            "$Result" | Should -Match $HelpSynopsisPattern
        }
    }
    Context 'using command: <Name>' -ForEach @(
            @{
                Name = 'completion'
                HelpInfo = @{
                    SynopsisPattern = '^Generate the autocompletion script for fizztool for the specified shell'
                    Tests = @(
                        @{
                            Condition = 'called without parameters'
                            Arguments = @()
                        }
                        @{
                            Condition = "called with '--help'"
                            Arguments = @('--help')
                        }
                    )
                }
                FunctionalTests = @()
            }
            @{
                Name = 'get'
                HelpInfo = @{
                    SynopsisPattern = '^Retrieve a key from the data store by name'
                    Tests = @(
                        @{
                            Condition = 'called without parameters'
                            Arguments = @()
                        }
                        @{
                            Condition = "called with '--help'"
                            Arguments = @('--help')
                        }
                    )
                }
                FunctionalTests = @(
                     @{
                        Description = "writes the copyright header and returns valid json with '--key fizz'"
                        Arguments = @('--key', 'fizz')
                        ExpectedExitCode = 0
                        Validation = {
                            "$Result" | Should -Match $LicensePattern
                        }
                        UnmungedValidation = {
                            $Result |
                                ConvertFrom-Json -ErrorAction Stop |
                                Select-Object -ExpandProperty 'fizz' |
                                Should -Be 'buzz'
                        }
                    }
                    @{
                        Description = "writes the copyright header and returns valid json with '-k fizz'"
                        Arguments = @('--key', 'fizz')
                        ExpectedExitCode = 0
                        Validation = {
                            "$Result" | Should -Match $LicensePattern
                        }
                        UnmungedValidation = {
                            $Result |
                                ConvertFrom-Json -ErrorAction Stop |
                                Select-Object -ExpandProperty 'fizz' |
                                Should -Be 'buzz'
                        }
                    }
                    @{
                        Description = "writes the copyright header and an error '--key buzz'"
                        Arguments = @('-k', 'buzz')
                        ExpectedExitCode = 1
                        ErrorMessage = [regex]::Escape('Error: key not found: buzz')
                        Validation = {
                            "$Result" | Should -Match $LicensePattern
                            "$Result" | Should -Match $ErrorMessage
                        }
                    }
                    @{
                        Description = "writes the copyright header and an error '-k buzz'"
                        Arguments = @('-k', 'buzz')
                        ExpectedExitCode = 1
                        ErrorMessage = [regex]::Escape('Error: key not found: buzz')
                        Validation = {
                            "$Result" | Should -Match $LicensePattern
                            "$Result" | Should -Match $ErrorMessage
                        }
                    }
                )
            }
            @{
                Name = 'help'
                HelpInfo = @{
                    SynopsisPattern = '^Help provides help for any command in the application'
                    Tests = @(
                        @{
                            Condition = "called with argument 'help'"
                            Arguments = @('help')
                        }
                        @{
                            Condition = "called with '--help'"
                            Arguments = @('--help')
                        }
                    )
                }
                FunctionalTests = @(
                    @{
                        Description = 'displays help for the application when called without arguments'
                        Arguments = @()
                        ExpectedExitCode = 0
                        Validation = {
                            $Result | Should -Match $HelpSynopsisPattern
                        }
                    }
                )
            }
            @{
                Name = 'version'
                HelpInfo = @{
                    SynopsisPattern = '^Display the extended version information for fizztool'
                    Tests = @(
                        @{
                            Condition = "called with '--help'"
                            Arguments = @('--help')
                        }
                    )
                }
                FunctionalTests = @(
                    @{
                        Description = 'displays extended version info as a valid json blob by default'
                        Arguments = @()
                        ExpectedExitCode = 0
                        Validation = {
                            $ObjectResult = $Result | ConvertFrom-Json
                            $ObjectResult.name | Should -Not -BeNullOrEmpty
                            $ObjectResult.version | Should -Not -BeNullOrEmpty
                            $ObjectResult.commit_sha | Should -Not -BeNullOrEmpty
                            $ObjectResult.release_notes_url | Should -Not -BeNullOrEmpty
                        }
                    }
                    @{
                        Description = "returns a short version string with '--one-line'"
                        Arguments = @('--one-line')
                        ExpectedExitCode = 0
                        Validation = {
                            $Result | Should -Match "$NamePattern - $VersionPattern"
                        }
                    }
                )
            }
        ) {
        It 'displays help info when <Condition>' -ForEach $HelpInfo.Tests {
            $Result = & $Application $Name @Arguments 2>&1
            $LASTEXITCODE | Should -Be 0
            "$Result" | Should -Match $HelpInfo.SynopsisPattern
        }

        It '<Description>' -ForEach $FunctionalTests {
            $Result = & $Application $Name @Arguments 2>&1
            $LASTEXITCODE | Should -Be $ExpectedExitCode
            $Validation.GetNewClosure().Invoke()

            if ($UnmungedValidation) {
                $Result = & $Application $Name @Arguments 2>$null
                $UnmungedValidation.GetNewClosure().Invoke()
            }
        }
    }
}
