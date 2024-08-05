# Search Script for Ivanti Application Control Configuration
#    sometimes containing whitelisted paths
#    Usage: ivanticonfig.ps1 -dir <dir> (default is C:)

param ([string]$dir = "C:\")
$tab = [char]9

Write-Host "Searching Ivanti Application Control installer and configuration files in $dir"
Write-Host ""

# search for installer (english and german)
Write-Host "[*] Searching for installer package"
$res = wmic product get name,localPackage | Select-String -Pattern "Ivanti Application Control [CK]onfiguration" -CaseSensitive
# wmic is deprecated and will be removed, alternatives (not working well):
# Get-Package -Name "Ivanti*" | Select-Object Name,FullPath
# (Get-CimInstance -ClassName Win32_Product | Where-Object Name -Like "Ivanti*").InstallLocation

if ($res) {
    Write-Host "[+] Installer found (open as ZIP and extract Configuration.xml):"
    Write-Host "$tab $res"
} else {
    Write-Host "[-] No installer found"
}


# search for configuration files
Write-Host ""
Write-Host "[*] Searching for configuration files in $dir (*.acconfig, *.aamp, Configuration.xml)"

$found = @()
$pattern = '.*\.acconfig|.*\.aamp|^Configuration\.xml'

Get-ChildItem -Path $dir -Recurse -ErrorAction SilentlyContinue -Force | Where {$_.Name -match $pattern} | % { $found += $_; Write-Host $tab $_.FullName }


if ($found.Count -gt 0) {
	Write-Host "[+]" $found.Count "configuration files found"
} else {
	Write-Host "[-] No configuration files found"
}

Write-Host "[*] Finished"
