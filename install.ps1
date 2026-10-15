# Installs, moves or reinstalls Smarcaz from the latest release here, without a browser download (so Windows
# SmartScreen has nothing to flag). Run in PowerShell:
#
#   irm https://raw.githubusercontent.com/RaresCroicia/smarcaz-releases/main/install.ps1 | iex
#
# It opens the installer, which asks where to install (for the current user, no administrator prompt) and whether to
# add a desktop shortcut (ticked). The app then keeps itself up to date in that folder.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$release = Invoke-RestMethod 'https://api.github.com/repos/RaresCroicia/smarcaz-releases/releases/latest' -Headers @{ 'User-Agent' = 'smarcaz-install' }
$asset = $release.assets | Where-Object name -like '*-Setup-*.exe' | Select-Object -First 1
if(-not $asset) { throw "Release $($release.tag_name) has no installer." }
$setup = Join-Path $env:TEMP $asset.name
Write-Host "Downloading Smarcaz $($release.tag_name)..."
Invoke-WebRequest $asset.browser_download_url -OutFile $setup -UseBasicParsing
# The installed app (found by its folder in the uninstall entry) is closed first, so its files can be replaced.
$entry = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{B6244B1D-324E-4357-9ED3-ED4008FDB69F}_is1'
$folder = (Get-ItemProperty $entry -ErrorAction SilentlyContinue).'Inno Setup: App Path'
if($folder) {
	Get-Process | Where-Object { $_.Path -and $_.Path.StartsWith("$folder\", 'OrdinalIgnoreCase') } | Stop-Process -Force -ErrorAction SilentlyContinue
}
Write-Host 'The installer is open: pick the folder and the desktop shortcut there.'
# Wait for the installer only: Start-Process -Wait would also wait for the app it starts at the end.
$process = Start-Process $setup -PassThru
$null = $process.Handle # keeps the exit code readable after it exits
$process.WaitForExit()
Remove-Item $setup -ErrorAction SilentlyContinue
if($process.ExitCode -eq 0) { Write-Host "Smarcaz $($release.tag_name) is installed." }
else { Write-Host 'The installation was cancelled.' }
