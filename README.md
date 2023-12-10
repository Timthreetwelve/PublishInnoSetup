# PublishInnoSetup
PowerShell scripts to publish Inno Setup installers

The PowerShell script is executed in the .csproj file only during Publish.  See the **Exec** statement near the end.
``` XML
  <!-- Publish to Inno Setup installer-->
    <Target Name="CompileSetup" AfterTargets="PublishZip">
      <PropertyGroup>
        <PowerShellScript>-File "D:\Visual Studio\Source\PowerShell\PublishInnoSetup\PubSetupEx.ps1"</PowerShellScript>
        <ScriptName>-issScript "$(ProjectDir)Inno_Setup\[Inno Setup script file]"</ScriptName>
      </PropertyGroup>

        <!-- This is the framework dependent version -->
        <PropertyGroup Condition="'$(PublishDir.Contains(`Framework_Dependent`))'">
            <PubType>-publishType ""</PubType>
        </PropertyGroup>

        <!-- This is the x64 self contained version-->
        <PropertyGroup Condition="'$(PublishDir.Contains(`Self_Contained_x64`))'">
            <PubType>-publishType SC_x64</PubType>
        </PropertyGroup>

        <!-- This is the x86 self contained version-->
        <PropertyGroup Condition="'$(PublishDir.Contains(`Self_Contained_x86`))'">
            <PubType>-publishType SC_x86</PubType>
        </PropertyGroup>

      <!-- Execute the PowerShell script -->
      <Exec Command="pwsh -NoProfile $(PowerShellScript) $(ScriptName) $(PublishDir) $(PubType) " />
    </Target>
```
