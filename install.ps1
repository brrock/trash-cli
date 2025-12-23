param(
    [string]$ReleaseTag = "latest"
)

$Repo = "brrock/trash-cli"
$BinaryName = "cli-bun-windows-x64.exe"
$DownloadUrl = "https://github.com/$Repo/releases/download/$ReleaseTag/$BinaryName"
$InstallDir = "$env:LOCALAPPDATA\Programs\trash-cli"
$TempPath = "$env:TEMP\$BinaryName"

Write-Host "Installing Trash CLI..." -ForegroundColor Green

# Create install directory
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

Write-Host "📦 Downloading from $DownloadUrl..." -ForegroundColor Cyan

try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempPath -UseBasicParsing
}
catch {
    Write-Host "❌ Failed to download: $_" -ForegroundColor Red
    exit 1
}

# Move to install directory
Move-Item -Path $TempPath -Destination "$InstallDir\trash-cli.exe" -Force

# Add to PATH if not already there
$PathItems = [Environment]::GetEnvironmentVariable("Path", "User") -split ";"
if ($PathItems -notcontains $InstallDir) {
    Write-Host "📍 Adding $InstallDir to PATH..." -ForegroundColor Yellow
    $NewPath = "$InstallDir;" + [Environment]::GetEnvironmentVariable("Path", "User")
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
}

Write-Host "✅ Installed to $InstallDir\trash-cli.exe" -ForegroundColor Green
Write-Host "🎉 Installation complete! Run 'trash-cli --help' to get started." -ForegroundColor Green
Write-Host "⚠️  You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Yellow