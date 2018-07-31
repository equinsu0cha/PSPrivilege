# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

$verbose = @{}
if ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $verbose.Add("Verbose", $true)
}

$ps_version = $PSVersionTable.PSVersion.Major
$module_name = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Import-Module -Name $PSScriptRoot\..\PSPrivilege -Force

Describe "$module_name PS$ps_version tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It "Gets all privileges" {
            $res = Get-ProcessPrivilege
            $res.Count -gt 0 | Should -Be $true
        }

        It "Gets an individual privilege" {
            $res = Get-ProcessPrivilege -Name "SeShutdownPrivilege"
            $res.Name | Should -Be "SeShutdownPrivilege"
            $res.Description | Should -Be "Shut down the system"
            $res.Enabled.GetType().Name | Should -Be "Boolean"
            $res.EnabledByDefault.GetType().Name | Should -Be "Boolean"
            $res.Attributes.GetType().Name | Should -Be "PrivilegeAttributes"
            $res.IsRemoved.GetType().Name | Should -Be "Boolean"
        }

        It "Gets an individual privilege with input as string" {
            $res = "SeShutdownPrivilege" | Get-ProcessPrivilege
            $res.Name | Should -Be "SeShutdownPrivilege"
            $res.Description | Should -Be "Shut down the system"
            $res.Enabled.GetType().Name | Should -Be "Boolean"
            $res.EnabledByDefault.GetType().Name | Should -Be "Boolean"
            $res.Attributes.GetType().Name | Should -Be "PrivilegeAttributes"
            $res.IsRemoved.GetType().Name | Should -Be "Boolean"
        }

        It "Gets an individual privilege with input as object" {
            $res = [PSCustomObject]@{Name="SeShutdownPrivilege"; Test=$true} | Get-ProcessPrivilege
            $res.Name | Should -Be "SeShutdownPrivilege"
            $res.Description | Should -Be "Shut down the system"
            $res.Enabled.GetType().Name | Should -Be "Boolean"
            $res.EnabledByDefault.GetType().Name | Should -Be "Boolean"
            $res.Attributes.GetType().Name | Should -Be "PrivilegeAttributes"
            $res.IsRemoved.GetType().Name | Should -Be "Boolean"
        }

        It "Gets multiple privileges" {
            $res = Get-ProcessPrivilege -Name SeUndockPrivilege, SeTimeZonePrivilege
            $res.Count | Should -Be 2
            $res[0].Name | Should -Be "SeUndockPrivilege"
            $res[0].Description | Should -Be "Remove computer from docking station"
            $res[1].Name | Should -Be "SeTimeZonePrivilege"
            $res[1].Description | Should -Be "Change the time zone"
        }

        It "Gets multiple privileges with input" {
            $res = "SeUndockPrivilege", "SeTimeZonePrivilege" | Get-ProcessPrivilege
            $res.Count | Should -Be 2
            $res[0].Name | Should -Be "SeUndockPrivilege"
            $res[0].Description | Should -Be "Remove computer from docking station"
            $res[1].Name | Should -Be "SeTimeZonePrivilege"
            $res[1].Description | Should -Be "Change the time zone"
        }

        It "Gets multiple privileges with input as object" {
            $res = [PSCustomObject]@{Name="SeUndockPrivilege"}, [PSCustomObject]@{Name="SeTimeZonePrivilege"} | Get-ProcessPrivilege
            $res.Count | Should -Be 2
            $res[0].Name | Should -Be "SeUndockPrivilege"
            $res[0].Description | Should -Be "Remove computer from docking station"
            $res[1].Name | Should -Be "SeTimeZonePrivilege"
            $res[1].Description | Should -Be "Change the time zone"
        }

        It "Get invalid privilege" {
            $res = Get-ProcessPrivilege -Name SeInvalid, SeUndockPrivilege -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -Be 1
            $err[0].CategoryInfo.Category | Should -Be "ObjectNotFound"
            $err[0].Exception.Message | Should -Be "Invalid privilege name 'SeInvalid'"

            $res.Name | Should -Be "SeUndockPrivilege"
        }

        It "Gets a privilege not present" {
            $res = Get-ProcessPrivilege -Name SeCreateTokenPrivilege
            $res.Name | Should -Be "SeCreateTokenPrivilege"
            $res.Description | Should -Be "Create a token object"
            $res.Enabled | Should -Be $false
            $res.EnabledByDefault | Should -Be $false
            $res.Attributes | Should -Be $null
            $res.IsRemoved | Should -Be $true
        }
    }
}