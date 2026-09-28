[CmdletBinding(SupportsShouldProcess)]
param(
    [switch] $SkipPackages,
    [switch] $SkipConfiguration
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$packageManifest = Join-Path $PSScriptRoot 'packages.json'
$profileSource = Join-Path $PSScriptRoot 'Microsoft.PowerShell_profile.ps1'
$terminalSource = Join-Path $PSScriptRoot 'terminal\dotfiles.json'
$profileStart = '# >>> jellydn/dotfiles >>>'
$profileEnd = '# <<< jellydn/dotfiles <<<'

function Write-Step([string] $Message) {
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Backup-File([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return
    }

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmssfff'
    $backupPath = "$Path.backup-$timestamp"
    Copy-Item -LiteralPath $Path -Destination $backupPath
    Write-Host "Backed up: $backupPath"
}

function Install-Packages {
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw 'WinGet is required. Install or update Microsoft App Installer, then run this script again: https://aka.ms/getwinget'
    }

    $manifest = Get-Content -LiteralPath $packageManifest -Raw | ConvertFrom-Json
    $failed = [System.Collections.Generic.List[string]]::new()

    foreach ($package in $manifest.packages) {
        if ($WhatIfPreference) {
            $null = $PSCmdlet.ShouldProcess($package.id, 'Install with WinGet')
            continue
        }

        $listArguments = @(
            'list', '--id', $package.id, '--exact', '--source', $manifest.source,
            '--accept-source-agreements', '--disable-interactivity'
        )
        & winget.exe @listArguments *> $null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Already installed: $($package.description) [$($package.id)]"
            continue
        }

        if (-not $PSCmdlet.ShouldProcess($package.id, 'Install with WinGet')) {
            continue
        }

        Write-Step "Installing $($package.description) [$($package.id)]"
        $installArguments = @(
            'install', '--id', $package.id, '--exact', '--source', $manifest.source,
            '--accept-source-agreements', '--accept-package-agreements', '--disable-interactivity'
        )
        & winget.exe @installArguments | Out-Host
        if ($LASTEXITCODE -ne 0) {
            $failed.Add($package.id)
        }
    }

    return ,$failed
}

function Get-PowerShellProfilePath {
    if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) {
        $path = & pwsh.exe -NoLogo -NoProfile -Command '$PROFILE.CurrentUserAllHosts'
        if ($LASTEXITCODE -eq 0 -and $path) {
            return [string] $path
        }
    }

    $documents = [Environment]::GetFolderPath('MyDocuments')
    return Join-Path $documents 'PowerShell\Profile.ps1'
}

function Install-PowerShellProfile {
    $profilePath = Get-PowerShellProfilePath
    $escapedSource = $profileSource.Replace("'", "''")
    $managedBlock = @"
$profileStart
. '$escapedSource'
$profileEnd
"@

    $content = if (Test-Path -LiteralPath $profilePath) {
        Get-Content -LiteralPath $profilePath -Raw
    } else {
        ''
    }

    $pattern = "(?ms)^$([regex]::Escape($profileStart)).*?^$([regex]::Escape($profileEnd))\r?\n?"
    $unmanagedContent = ([regex]::Replace($content, $pattern, '')).TrimEnd()
    $newContent = if ($unmanagedContent) {
        "$unmanagedContent`r`n`r`n$managedBlock`r`n"
    } else {
        "$managedBlock`r`n"
    }

    if ($content -eq $newContent) {
        Write-Host "PowerShell profile is current: $profilePath"
        return
    }

    if ($PSCmdlet.ShouldProcess($profilePath, 'Install managed profile loader')) {
        Backup-File $profilePath
        $null = New-Item -ItemType Directory -Path (Split-Path -Parent $profilePath) -Force
        $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($profilePath, $newContent, $utf8WithoutBom)
        Write-Host "Installed PowerShell profile loader: $profilePath"
    }
}

function Install-TerminalFragment {
    $fragmentDirectory = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\jellydn-dotfiles'
    $fragmentPath = Join-Path $fragmentDirectory 'dotfiles.json'
    $sourceContent = Get-Content -LiteralPath $terminalSource -Raw
    $destinationContent = if (Test-Path -LiteralPath $fragmentPath) {
        Get-Content -LiteralPath $fragmentPath -Raw
    } else {
        $null
    }

    if ($sourceContent -eq $destinationContent) {
        Write-Host "Windows Terminal fragment is current: $fragmentPath"
        return
    }

    if ($PSCmdlet.ShouldProcess($fragmentPath, 'Install Windows Terminal fragment')) {
        Backup-File $fragmentPath
        $null = New-Item -ItemType Directory -Path $fragmentDirectory -Force
        Copy-Item -LiteralPath $terminalSource -Destination $fragmentPath -Force
        Write-Host "Installed Windows Terminal fragment: $fragmentPath"
    }
}

if ($env:OS -ne 'Windows_NT') {
    throw 'This setup script supports Windows only.'
}

$build = [Environment]::OSVersion.Version.Build
if ($build -lt 22000) {
    throw "Windows 11 build 22000 or newer is required. Detected build: $build"
}

Write-Host "Windows 11 dotfiles setup from $repoRoot" -ForegroundColor Green
$packageFailures = [System.Collections.Generic.List[string]]::new()

if (-not $SkipPackages) {
    $packageFailures = Install-Packages
}

if (-not $SkipConfiguration) {
    Install-PowerShellProfile
    Install-TerminalFragment
}

if ($packageFailures.Count -gt 0) {
    throw "WinGet could not install: $($packageFailures -join ', '). Re-run setup after you resolve the reported WinGet errors."
}

Write-Host 'Windows setup complete. Open a new Windows Terminal session.' -ForegroundColor Green
