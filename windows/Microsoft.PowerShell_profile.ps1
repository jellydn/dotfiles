# Shared PowerShell 7 settings. windows/setup.ps1 loads this from the user profile.
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vim -Value nvim
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& zoxide init powershell | Out-String)
}

function ll {
    Get-ChildItem -Force @args
}

function which {
    Get-Command @args
}
