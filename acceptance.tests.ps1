param (
    [Parameter(Mandatory)]
    [System.Management.Automation.ApplicationInfo] $Application
)

BeforeAll {
    $HelpSynopsisPattern = '^fizztool is a small application that emits output for test scenarios.'
    $LicensePattern = [regex]::Escape('fizztool.exe v1.0.0 (c) 2021 Tailspin Toys, Ltd.')
}
  
Describe 'Functionality - <Application>' -Tag Acceptance {
    Context 'Without parameters' {
        It 'Displays help info' {
            $Result = & $Application 2>&1
            $LASTEXITCODE | Should -Be 0
            $Result | Should -Not -BeNullOrEmpty
            "$Result" | Should -Match $HelpSynopsisPattern
        }
    }
    Context 'With known arguments: <Arguments>' -ForEach @(
        @{
            Arguments = @('help')
            Expected = 'returns help info'
        }
        @{
            Arguments = @('--help')
            Expected = 'returns help info'
        }
        @{
            Arguments = @('--key', 'fizz')
            Expected = 'runs successfully'
        }
        @{
            Arguments = @('-k', 'fizz')
            Expected = 'runs successfully'
        }
        @{
            Arguments = @('--key', 'buzz')
            Expected = 'fails'
        }
        @{
            Arguments = @('-k', 'buzz')
            Expected = 'fails'
        }
    ) {
        It "<Expected>" {
            $Result = & $Application @Arguments 2>&1
            $ExitCode = $LASTEXITCODE
            switch ($Expected) {
                'returns help info' {
                    $ExitCode | Should -Be 0
                    "$Result" | Should -Match $HelpSynopsisPattern
                }
                'runs successfully' {
                    $ExitCode | Should -Be 0
                    "$Result" | Should -Match $LicensePattern
                    & $Application @Arguments |
                        ConvertFrom-Json -ErrorAction Stop |
                        Select-Object -ExpandProperty 'fizz' |
                        Should -Be 'buzz'
                }
                'fails' {
                    $ExitCode | Should -Be 1
                    "$Result" | Should -Match $LicensePattern
                    "$Result" | Should -Match "Error: Key not found: $($Arguments[-1])"
                }
            }
        }
    }
    Context 'With an unknown flag in arguments: <Arguments>' -ForEach @(
        @{ Arguments = @('--ping', 'pong') }
        @{ Arguments = @('--key', 'fizz', '--ping', 'pong') }
        @{ Arguments = @('--key', 'buzz', '--ping', 'pong') }
    ) {
        It 'Errors usefully' {
            $Result = & $Application @Arguments 2>&1
            $LASTEXITCODE | Should -Be 1
            "$Result" | Should -Not -Match $LicensePattern
            "$Result" | Should -Match 'Error: unknown flag: --ping'
        }
    }
}
