# Ivanti Application Control - Configuration Searcher
Search script for Ivanti Application Control configurations, sometimes containing whitelisted paths.

## Powershell
- see ivanticonfig.ps1

## cmd.exe
If Powershell is not usable on the target, run the following in command prompt:
1. `wmic product get name,localPackage | findstr "Ivanti Application Control Configuration"` (German: Konfiguration)
   - if .msi found, open as ZIP and extract Configuration.xml
3. `dir /s *.acconfig *.aamp Configuration.xml`
