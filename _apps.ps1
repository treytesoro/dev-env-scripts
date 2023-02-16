$fullscriptpath = $MyInvocation.MyCommand.Path
$parentdir = $fullscriptpath.SubString(0, $fullscriptpath.LastIndexOf("\"))

Write-Host "========================================="
Write-Host "Starting user space app installations..."
Write-Host "========================================="
Write-Host ""


Write-Host "Installing VSCode..."
winget install vscode -h --accept-source-agreements --accept-package-agreements | Out-Null
Write-Host "Installing NodeJS LTS..."
winget install "Node.js LTS" -h --accept-source-agreements --accept-package-agreements | Out-Null
Write-Host "Intalling Git..."
winget install git.git -h --accept-source-agreements --accept-package-agreements | Out-Null


Write-Host ""
Write-Host "Installing Ubuntu-22.04 into WSL2..."
wsl --install --distribution Ubuntu-22.04
Write-Host ""
Write-Host "================================================"
Write-Host "Starting Ubuntu to complete user setup."
Write-Host "When you're finished creating the default user,"
Write-Host "exit the ubuntu session to begin setting up"
Write-Host "your distro's Docker environment."
Write-Host "================================================"
Write-Host ""

ubuntu2204.exe

Set-Location $parentdir
wsl ./setupwsl.sh


PAUSE

