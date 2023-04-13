#!/usr/bin/env pwsh

[CmdletBinding()]
param (
  [Parameter()]
  [ValidateSet('build', 'package', 'test')]
  [string]$Target = 'build'
)

function Build-Project {
    [cmdletbinding()]
    [OutputType([System.Management.Automation.ApplicationInfo])]
    param(
        [switch]$All
    )
    if ($All) {
        goreleaser release --skip-publish --skip-announce --skip-validate --clean --release-notes ./RELEASE_NOTES.md
    } else {
        goreleaser build --snapshot --clean --single-target
    }
    Get-Command "./dist/fizztool*/fizztool*" -ErrorAction Stop
}

switch ($Target) {
    'build' {
        Build-Project
    }
    'package' {
        Build-Project -All
    }
    'test' {
        $Application = Build-Project
        $TestContainer = New-PesterContainer -Path 'acceptance.tests.ps1' -Data @{
            Application = $Application
        }
        Invoke-Pester -Container $TestContainer -Output Detailed
    }
}