[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$failures = [System.Collections.Generic.List[string]]::new()

function Assert([bool] $Condition, [string] $Message) {
    if (-not $Condition) {
        $failures.Add($Message)
    }
}

Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.ps1' | ForEach-Object {
    $tokens = $null
    $errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref] $tokens, [ref] $errors)
    if ($errors.Count -gt 0) {
        $failures.Add("$($_.Name) has PowerShell syntax errors: $($errors.Message -join '; ')")
    }
}

$rootBootstrap = Join-Path (Split-Path -Parent $PSScriptRoot) 'bootstrap.ps1'
$tokens = $null
$errors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile($rootBootstrap, [ref] $tokens, [ref] $errors)
if ($errors.Count -gt 0) {
    $failures.Add("bootstrap.ps1 has PowerShell syntax errors: $($errors.Message -join '; ')")
}

$packages = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'packages.json') -Raw | ConvertFrom-Json
Assert ($packages.source -eq 'winget') 'packages.json must use the winget source.'
Assert ($packages.packages.Count -gt 0) 'packages.json must contain packages.'
$packageIds = @($packages.packages | ForEach-Object { $_.id })
Assert (($packageIds | Sort-Object -Unique).Count -eq $packageIds.Count) 'Package IDs must be unique.'
Assert (@($packageIds | Where-Object { $_ -notmatch '^[A-Za-z0-9]+(?:[._-][A-Za-z0-9]+)+$' }).Count -eq 0) 'Package IDs must use exact WinGet identifier syntax.'

$terminal = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'terminal\dotfiles.json') -Raw | ConvertFrom-Json
Assert ($terminal.profiles.Count -eq 1) 'The Terminal fragment must define one profile.'
Assert ($terminal.profiles[0].commandline -eq 'pwsh.exe') 'The Terminal profile must start PowerShell 7.'
Assert ($terminal.schemes.Count -eq 1) 'The Terminal fragment must define one color scheme.'
$requiredColors = @('black', 'red', 'green', 'yellow', 'blue', 'purple', 'cyan', 'white', 'brightBlack', 'brightRed', 'brightGreen', 'brightYellow', 'brightBlue', 'brightPurple', 'brightCyan', 'brightWhite')
foreach ($color in $requiredColors) {
    Assert ($null -ne $terminal.schemes[0].$color) "Terminal color scheme is missing $color."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host 'Windows configuration validation passed.' -ForegroundColor Green
