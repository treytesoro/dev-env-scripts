$fullscriptpath = $MyInvocation.MyCommand.Path
# This is the path to the user space script.
$scriptpath = $fullscriptpath.SubString(0, $fullscriptpath.LastIndexOf("\"))+"\_apps.ps1"


# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

$doSetup = "0";
do {
    Write-Host "===========================================================";
    Write-Host "      This will setup Trey's standard dev enviroment:      ";
    Write-Host "                                                           ";
    Write-Host "            Y: Press Y to begin setup                      ";
    Write-Host "       CANCEL: Press N to cancel.                          ";
    Write-Host "===========================================================";
    $doSetup = Read-Host -Prompt '(Y/N)';
} until ($doSetup.ToLower() -eq "y" -or $doSetup.ToLower() -eq "n");

if($doSetup -eq "n") {
	exit;
}

# Registry to start userspace app install after reboot.
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
$Name         = 'continue_dev_setup'
$Value        = "C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File `"$scriptpath`" -NoExit"
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType String -Force | Out-Null

$isHyperVEnabled = if((dism /online /get-features /Format:Table | findstr "Hyper-V" | findstr "Enabled").Length -gt 0) { $true } else { $false }

if(!$isHyperVEnabled) {
	Write-Host ""
	Write-Host "========================================="
	Write-Host "Enabling Microsoft-Hyper-V."
	Write-Host "Your computer will reboot when complete."
	Write-Host "Login after reboot to continue setup."
	Write-Host "========================================="
	Write-Host ""
	Write-Host "Please wait..."
	DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V /Quiet
}

# Write-Host "Installing VSCode..."
# winget install vscode -h --accept-source-agreements --accept-package-agreements | Out-Null
# Write-Host "Installing NodeJS LTS..."
# winget install "Node.js LTS" -h --accept-source-agreements --accept-package-agreements | Out-Null
# Write-Host "Intalling Git..."
# winget install git.git -h --accept-source-agreements --accept-package-agreements | Out-Null


#$parentdir = $fullscriptpath.SubString(0, $fullscriptpath.LastIndexOf("\"))
# if($isHyperVEnabled) {
	# Write-Host "Installing Ubuntu-22.04 into WSL2..."
	# wsl --install --distribution Ubuntu-22.04
	# Write-Host "Starting Ubuntu to complete user setup..."
	# ubuntu2204.exe
	
	# Set-Location $parentdir
	# wsl ./setupwsl.sh
	# PAUSE
# }
