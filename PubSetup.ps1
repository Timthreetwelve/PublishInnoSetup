# This is a PowerShell script that will compile the installer
#
# To call it, add something similar to the following to the project file:
#
# <Target Name="CompileSetup" AfterTargets="PublishZip">
#   <PropertyGroup>
#     <PowerShellScript>-File "D:\Visual Studio\Source\PowerShell\PublishInnoSetup\PubSetup.ps1"</PowerShellScript>
#     <ScriptName>-issScript "D:\InnoSetup\TimVer.iss"</ScriptName>
#   </PropertyGroup>
#   <Exec Command="pwsh -NoProfile $(PowerShellScript) $(ScriptName)" />
# </Target>
#

Param(
    [Parameter(Mandatory = $true)] [string] $issScript
)

# Stop if there is an error
$ErrorActionPreference = "Stop"

# Begin message
$now = (Get-Date).ToString("HH:mm:ss.ff")
Write-Host "PubSetup: entering script at $now"

# Verify Inno Setup compiler
$iscc = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if (-not( Test-Path $iscc)) {
    Write-Host "PubSetup: Inno Setup compiler not found."
    [Environment]::Exit(1)
}

# If script filename doesn't end will .iss, add it
$issScript = $issScript.Trim()
if (-not $issScript.EndsWith(".iss")) {
    $issScript = -join ($issScript, ".iss")
}

# Verify script file exists
if (-not (Test-Path $issScript)) {
    Write-Host "PubSetup: Inno Setup script could not be found: $issScript"
    [System.Environment]::Exit(2)
}
Write-Host "PubSetup: Inno Setup Script is: $issScript"

# Start the compiler
Start-Process -FilePath "$iscc" -ArgumentList "/Q `"$issScript`"" -NoNewWindow -Wait

# Finished message
$now = (Get-Date).ToString("HH:mm:ss.ff")
Write-Host "PubSetup: script completed at $now"

# open the output folder in file explorer
Invoke-Item D:\InnoSetup\Output
