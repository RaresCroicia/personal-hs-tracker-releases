# Installs, moves or reinstalls BG Tracker from the latest release here, without a browser download (so Windows
# SmartScreen has nothing to flag). Run in PowerShell:
#
#   irm https://raw.githubusercontent.com/RaresCroicia/helper-tracker-releases/main/install.ps1 | iex
#
# It opens the installer, which asks where to install (for the current user, no administrator prompt; by default
# %LocalAppData%\Programs\BG Tracker) and whether to add a desktop shortcut (ticked). The tracker then keeps itself
# up to date in that folder.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$release = Invoke-RestMethod 'https://api.github.com/repos/RaresCroicia/helper-tracker-releases/releases/latest' -Headers @{ 'User-Agent' = 'bg-tracker-install' }
$asset = $release.assets | Where-Object name -like 'BgTracker-Setup-*.exe' | Select-Object -First 1
if(-not $asset) { throw "Release $($release.tag_name) has no installer." }
$setup = Join-Path $env:TEMP $asset.name
Write-Host "Downloading BG Tracker $($release.tag_name)..."
Invoke-WebRequest $asset.browser_download_url -OutFile $setup -UseBasicParsing
Write-Host 'The installer is open: pick the folder and the desktop shortcut there.'
# Wait for the installer only: Start-Process -Wait would also wait for the tracker it starts at the end.
$process = Start-Process $setup -PassThru
$null = $process.Handle # keeps the exit code readable after it exits
$process.WaitForExit()
Remove-Item $setup -ErrorAction SilentlyContinue
if($process.ExitCode -eq 0) { Write-Host "BG Tracker $($release.tag_name) is installed." }
else { Write-Host 'The installation was cancelled.' }
