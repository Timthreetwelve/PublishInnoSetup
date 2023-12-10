#
# This is a PowerShell script that will compile the Inno Setup Installer
#
# To call it add something similar to the following to the project file:
#
#  <Target Name="CompileSetup" AfterTargets="PublishZip">
#    <PropertyGroup>
#      <PowerShellScript>-File "D:\Visual Studio\Source\PowerShell\PublishInnoSetup\PubSetupEx.ps1"</PowerShellScript>
#      <ScriptName>-issScript "$(ProjectDir)Inno_Setup\GetMyIPEx.iss"</ScriptName>
#    </PropertyGroup>
#    <PropertyGroup Condition="'$(PublishDir.Contains(`Self_Contained_x64`))'">
#      <PubType>-publishType SC_x64</PubType>
#    </PropertyGroup>
#  </Target>

# Parameters. If $publishType is empty it will be set to string.empty
Param(
    [Parameter(Mandatory = $true)] [string] $issScript,
    [Parameter(Mandatory = $true)] [string] $publishFolder,
    [Parameter(Mandatory = $false)] [string] $publishType
)

# Stop if there is an error
$ErrorActionPreference = "Stop"

# Start timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

# Begin message
$now = (Get-Date).ToString("HH:mm:ss.ff")
Write-Host "PubSetup: entering script at $now"
Write-Host "PubZip: Inno Setup script  : $issScript"
Write-Host "PubZip: Publish Folder     : $publishFolder"
Write-Host "PubZip: Publish type       : $publishType"

# Verify Inno Setup compiler location
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

# Remove any spaces from the ends of the variable
if ($null -eq $publishType) {
    $publishType = [String]::Empty
}
else {
    $publishType = $publishType.Trim()
}

# Remove trailing slash
if ($publishFolder.EndsWith('\')) {
    $publishFolder = $publishFolder.TrimEnd('\')
}

# Add beginning slash
if (-not ($publishFolder.StartsWith('\'))) {
    $publishFolder = [string]::Concat("\", $publishFolder)
}

# Create a file name in the temp folder
$tempPath = [System.IO.Path]::GetTempPath()
$ourFile = "PubSetup.Temp.iss"
$tempFile = Join-Path $tempPath $ourFile

# Contents of PubSetup.Temp.iss
$define1 = "#define InstallType `"$publishType`""
$define2 = "#define PublishFolder `"$publishFolder`""

# Write the file putting each statement on a separate line.
# This will overwrite a file with the same name.
try {
    Write-Host "PubZip: Writing $tempFile."
    $fileContent = $define1
    $fileContent += "`r`n"
    $fileContent += $define2
    Set-Content $tempFile $fileContent
}
catch {
    Write-Host "Could not write to $tempFile."
    [System.Environment]::Exit(3)
}
Write-Host "PubSetup: Elapsed time $([Math]::round($elapsed.Elapsed.TotalSeconds,4)) seconds."

# Start the compiler passing the script name
Write-Host "PubSetup: Beginning build of Inno Setup installer."
Start-Process -FilePath "$iscc" -ArgumentList "/Q `"$issScript`"" -NoNewWindow -Wait

# Finished message
$now = (Get-Date).ToString("HH:mm:ss.ff")
Write-Host "PubSetup: Script completed at $now."
Write-Host "PubSetup: Elapsed time $([Math]::round($elapsed.Elapsed.TotalSeconds,4)) seconds."

# open the output folder in file explorer
Invoke-Item D:\InnoSetup\Output

# Cleanup
Remove-Item $tempFile
