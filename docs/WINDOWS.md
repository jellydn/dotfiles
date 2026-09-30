# Windows 11 setup

Windows uses a native PowerShell and WinGet setup. It does not use GNU Stow or
change the Linux and macOS setup.

## Prerequisites

- Windows 11 (build 22000 or newer)
- [WinGet](https://learn.microsoft.com/windows/package-manager/winget/), supplied by Microsoft App Installer

## One-line installer

Open Windows PowerShell and run:

```powershell
$tmp = Join-Path ([IO.Path]::GetTempPath()) "dotfiles-$([guid]::NewGuid()).ps1"; try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/jellydn/dotfiles/master/bootstrap.ps1 -OutFile $tmp; Unblock-File $tmp; Set-ExecutionPolicy -Scope Process RemoteSigned; & $tmp } finally { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
```

The bootstrap installs Git through WinGet when needed, clones to `~/.dotfiles`,
and runs the setup. It updates an existing clean checkout only by fast-forward and
refuses to replace unrelated files or discard local changes. Use `& $tmp -WhatIf`
inside the command to preview setup after cloning. Set `DOTFILES_DIR` before the
command to select another stable checkout path.

Review `bootstrap.ps1` and `windows/setup.ps1` before use. The downloaded script
runs with your user permissions, and WinGet installers can request elevation. To pin
a reviewed version, use its commit SHA in the download URL and set
`DOTFILES_BRANCH` to the same SHA.

## Manual installation

Git and a clone in a stable path are required for manual installation.

Open Windows PowerShell in the repository root. Preview all actions first:

```powershell
Get-ChildItem .\windows -Recurse -Filter *.ps1 | Unblock-File
Set-ExecutionPolicy -Scope Process RemoteSigned
.\windows\setup.ps1 -WhatIf
```

Review the scripts before you run `Unblock-File`. This command removes the
`Zone.Identifier` Internet-download marker from only the repository's
PowerShell scripts. Windows can apply this marker to all files extracted from
a downloaded ZIP archive. Under `RemoteSigned`, unsigned marked scripts cannot
run even when the process policy was set successfully.

The process-scoped policy ends when this PowerShell window closes. The setup
does not change the saved execution policy. An organization policy can still
prevent scripts from running; do not bypass that policy.

Apply the setup:

```powershell
.\windows\setup.ps1
```

No administrator session is required by the script. Individual WinGet
installers can request elevation. The package list is in
`windows/packages.json`, with exact IDs from the official WinGet community
repository. Re-running setup skips installed packages and refreshes managed
configuration.

Use `-SkipPackages` or `-SkipConfiguration` to apply only one part.

## Managed configuration

- `windows/Microsoft.PowerShell_profile.ps1` is loaded from a marked block in
  the PowerShell 7 `CurrentUserAllHosts` profile. Existing profile content is
  kept. A timestamped backup is made before a change.
- `windows/terminal/dotfiles.json` is copied to the official per-user Windows
  Terminal fragment directory. It adds a **Dotfiles PowerShell** profile and
  the Kanagawa Wave color scheme without editing `settings.json`.

The loader contains the absolute repository path. Re-run setup after moving
the clone. To remove the integration, delete the marked `jellydn/dotfiles`
block from `$PROFILE.CurrentUserAllHosts` and delete:

```text
%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\jellydn-dotfiles
```

Package removal is intentionally manual. Review installed packages with
`winget list` before using `winget uninstall --id <exact-id>`.

## Validation

Run the built-in validation in PowerShell 7:

```powershell
pwsh -NoProfile -File .\windows\Test-Setup.ps1
```

The test parses all Windows PowerShell files and validates the package manifest
and complete Windows Terminal color scheme.

## Official references

- [WinGet install command](https://learn.microsoft.com/windows/package-manager/winget/install)
- [Windows Terminal JSON fragments](https://learn.microsoft.com/windows/terminal/json-fragment-extensions)
- [PowerShell profiles](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles)
- [PowerShell execution policies](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies)
- [Unblock-File](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/unblock-file)
