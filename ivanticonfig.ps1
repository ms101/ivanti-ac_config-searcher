# Search Script for Ivanti Application Control Configuration
#    sometimes containing whitelisted paths
#    Usage: ivanticonfig.ps1 -dir <dir> (default is C:)

param ([string]$dir = "C:\")
$tab = [char]9
$configFiles = @("configuration.aamp", "configuration.acconfig")
$packagePattern = "Ivanti Application Control [CK]onfiguration"

Write-Host "Searching Ivanti Application Control installer and configuration files"
Write-Host "$tab Directory: $dir"
Write-Host ""

# search for installer by package name (english and german)
Write-Host "[*] Searching for installer package ($packagePattern)"
$res = wmic product get name,localPackage | Select-String -Pattern $packagePattern -CaseSensitive
# wmic is deprecated and will be removed, alternatives (not working well):
# Get-Package -Name "Ivanti*" | Select-Object Name,FullPath
# (Get-CimInstance -ClassName Win32_Product | Where-Object Name -Like "Ivanti*").InstallLocation

if ($res) {
    Write-Host -ForegroundColor Green "[+] Installer found:"
    Write-Host "$tab $res"
    Write-Host "[*] Open as ZIP and extract configuration.aamp/.acconfig, open as ZIP and extract Configuration.xml"
} else {
    Write-Host -ForegroundColor Red "[-] No installer found by package name"
}

# search for config file in C:\Windows\Installer\*.msi via ComObject
Write-Host ""
Write-Host "[*] Searching for configuration in .msi installer packages"

$msiFiles = Get-ChildItem -Path "C:\Windows\Installer" -Recurse -Force -Filter *.msi
$notFound = $true

foreach ($f in $msiFiles) {
    # Create a new Windows Installer COM object
    $installer = New-Object -ComObject WindowsInstaller.Installer
    $database = $installer.OpenDatabase($f.FullName, 0)

    # Get the list of files in .msi
    $view = $database.OpenView("SELECT FileName FROM File")
    $view.Execute()

    # Loop through the file entries
    $record = $view.Fetch()
    while ($record -ne $null) {
        $fileName = $record.StringData(1)

        if ($fileName.Contains("|")) {
            $fileName = $fileName.Remove(0, $fileName.IndexOf("|") + 1)
        }

        # Check if the file name matches any of the search criteria
        if ($configFiles -contains $fileName) {
            Write-Host -ForegroundColor Green "[+] Found '$fileName' in '$($f.FullName)'"
            $notFound = $false
        }

        $record = $view.Fetch()
    }

    $view.Close()
    $database = $null
    $installer = $null
}
if ($notFound) {
    Write-Host -ForegroundColor Red "[-] No configuration found"
}

# search for configuration files in file system
Write-Host ""
Write-Host "[*] Searching for configuration files in $dir (*.acconfig, *.aamp, Configuration.xml)"

$found = @()
$pattern = '.*\.acconfig|.*\.aamp|^Configuration\.xml'

Get-ChildItem -Path $dir -Recurse -ErrorAction SilentlyContinue -Force | Where {$_.Name -match $pattern} | % { $found += $_; Write-Host $tab $_.FullName }


if ($found.Count -gt 0) {
	Write-Host -ForegroundColor Green "[+]" $found.Count "configuration files found"
} else {
	Write-Host -ForegroundColor Red "[-] No configuration files found in file system"
}

Write-Host "[*] Finished"
