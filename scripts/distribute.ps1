<#
.SYNOPSIS
    Build a release APK and distribute it to testers via Firebase App Distribution.

.DESCRIPTION
    One-command update flow for the maktoob app:
      1. Builds a release APK (with --no-tree-shake-icons, required because venue
         icons are data-driven IconData from the backend).
      2. Uploads it to Firebase App Distribution and distributes to the 'qa' group.

    Every run creates a NEW release. Testers already in the group are NOT re-invited;
    they just see an update in the Firebase "App Tester" app.

.PARAMETER Notes
    Release notes shown to testers. Defaults to a generic message.

.PARAMETER Group
    App Distribution group alias to distribute to. Defaults to 'qa'.

.PARAMETER SkipBuild
    Skip the flutter build step and distribute the existing app-release.apk.

.EXAMPLE
    ./scripts/distribute.ps1 -Notes "Fixed login bug + new event card design"

.EXAMPLE
    ./scripts/distribute.ps1 -SkipBuild -Notes "Re-sending last build"
#>
param(
    [string]$Notes = "New test build",
    [string]$Group = "qa",
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

# Firebase app/project for maktoob (Android).
$AppId   = "1:655305126360:android:0459c3a8dc22d3587802ad"
$Project = "maktoob-4c504"
$Apk     = "build/app/outputs/flutter-apk/app-release.apk"

# Always run from the repo root (this script lives in scripts/).
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

if (-not $SkipBuild) {
    Write-Host "==> Building release APK..." -ForegroundColor Cyan
    flutter build apk --release --no-tree-shake-icons
    if ($LASTEXITCODE -ne 0) { throw "flutter build failed (exit $LASTEXITCODE)" }
}

if (-not (Test-Path $Apk)) { throw "APK not found at $Apk" }

Write-Host "==> Distributing to group '$Group'..." -ForegroundColor Cyan
firebase appdistribution:distribute $Apk `
    --app $AppId `
    --project $Project `
    --groups $Group `
    --release-notes $Notes
if ($LASTEXITCODE -ne 0) { throw "firebase distribute failed (exit $LASTEXITCODE)" }

Write-Host "==> Done. Testers in '$Group' will see the update in App Tester." -ForegroundColor Green
