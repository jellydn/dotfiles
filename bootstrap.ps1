[CmdletBinding()]
param(
    [string] $InstallDirectory = $(if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Join-Path $HOME '.dotfiles' }),
    [string] $Ref = $(if ($env:DOTFILES_BRANCH) { $env:DOTFILES_BRANCH } else { 'master' }),
    [switch] $WhatIf,
    [switch] $SkipPackages,
    [switch] $SkipConfiguration
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoUrl = if ($env:DOTFILES_REPO_URL) { $env:DOTFILES_REPO_URL } else { 'https://github.com/jellydn/dotfiles.git' }

function Write-Step([string] $Message) {
    Write-Host "[dotfiles] $Message" -ForegroundColor Cyan
}

function Invoke-Git([string[]] $Arguments) {
    & git.exe @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git failed with exit code $LASTEXITCODE`: git $($Arguments -join ' ')"
    }
}

function Install-Git {
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw 'Git is missing and WinGet is unavailable. Install Microsoft App Installer from https://aka.ms/getwinget, then retry.'
    }

    Write-Step 'Installing required tool: Git'
    & winget.exe install --id Git.Git --exact --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity
    if ($LASTEXITCODE -ne 0) {
        throw "WinGet could not install Git.Git (exit code $LASTEXITCODE)."
    }

    $machineGit = Join-Path $env:ProgramFiles 'Git\cmd'
    $userGit = Join-Path $env:LOCALAPPDATA 'Programs\Git\cmd'
    $env:Path = "$machineGit;$userGit;$env:Path"
    if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
        throw 'Git was installed but is not on PATH. Open a new PowerShell window and run the command again.'
    }
}

if ($env:OS -ne 'Windows_NT') {
    throw 'This bootstrap supports Windows 11 only. On macOS or Linux, use bootstrap.sh.'
}

$build = [Environment]::OSVersion.Version.Build
if ($build -lt 22000) {
    throw "Windows 11 build 22000 or newer is required. Detected build: $build"
}

if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
    Install-Git
}

if (Test-Path -LiteralPath $InstallDirectory) {
    $gitDirectory = Join-Path $InstallDirectory '.git'
    if (-not (Test-Path -LiteralPath $gitDirectory -PathType Container)) {
        throw "$InstallDirectory exists but is not a Git checkout. Move it aside or set DOTFILES_DIR."
    }

    $currentOrigin = (& git.exe -C $InstallDirectory remote get-url origin 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $currentOrigin) {
        throw "$InstallDirectory has no origin remote. Refusing to update it."
    }
    $normalizedOrigin = $currentOrigin -replace '\.git$', ''
    $normalizedRepoUrl = $repoUrl -replace '\.git$', ''
    if ($normalizedOrigin -ne $normalizedRepoUrl) {
        throw "$InstallDirectory origin is '$currentOrigin', not '$repoUrl'. Refusing to update it."
    }
    $changes = (& git.exe -C $InstallDirectory status --porcelain=v1 --untracked-files=all --ignore-submodules=none)
    if ($LASTEXITCODE -ne 0) {
        throw "Could not inspect $InstallDirectory."
    }
    if ($changes) {
        throw "$InstallDirectory has local changes. Commit or stash them before retrying."
    }

    Write-Step "Updating $InstallDirectory (fast-forward only)..."
    Invoke-Git @('-C', $InstallDirectory, 'fetch', '--quiet', 'origin', $Ref)
    & git.exe -C $InstallDirectory merge-base --is-ancestor HEAD FETCH_HEAD
    if ($LASTEXITCODE -ne 0) {
        throw "$InstallDirectory is ahead of or has diverged from '$Ref'. Refusing to change it."
    }
    Invoke-Git @('-C', $InstallDirectory, 'merge', '--ff-only', 'FETCH_HEAD')
    $headCommit = (& git.exe -C $InstallDirectory rev-parse HEAD)
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve the current revision in $InstallDirectory."
    }
    $targetCommit = (& git.exe -C $InstallDirectory rev-parse FETCH_HEAD)
    if ($LASTEXITCODE -ne 0 -or $headCommit -ne $targetCommit) {
        throw "$InstallDirectory did not reach the requested revision. Refusing to run the installer."
    }
} else {
    $parent = Split-Path -Parent $InstallDirectory
    if ($parent) {
        $null = New-Item -ItemType Directory -Path $parent -Force
    }
    Write-Step "Cloning $repoUrl to $InstallDirectory..."
    Invoke-Git @('clone', '--quiet', $repoUrl, $InstallDirectory)
    Invoke-Git @('-C', $InstallDirectory, 'checkout', '--quiet', $Ref)
}

$setup = Join-Path $InstallDirectory 'windows\setup.ps1'
if (-not (Test-Path -LiteralPath $setup -PathType Leaf)) {
    throw "Missing installer: $setup"
}
Write-Step "Running $setup"
& $setup -WhatIf:$WhatIf -SkipPackages:$SkipPackages -SkipConfiguration:$SkipConfiguration
