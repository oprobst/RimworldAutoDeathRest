# Build-Skript fuer den Auto-Deathrest Mod.
# Voraussetzung: .NET SDK (>=6) installiert -> https://dotnet.microsoft.com/download
# Verwendung:    .\build.ps1  [-RimWorldPath "D:\SteamLibrary\steamapps\common\RimWorld"]

param(
    [string]$RimWorldPath = "D:\SteamLibrary\steamapps\common\RimWorld",
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"
$projectPath = Join-Path $PSScriptRoot "Source\AutoDeathRest\AutoDeathRest.csproj"

if (-not (Test-Path "$RimWorldPath\RimWorldWin64_Data\Managed\Assembly-CSharp.dll")) {
    Write-Error "RimWorld nicht gefunden unter '$RimWorldPath'. Parameter -RimWorldPath anpassen."
}

& dotnet build $projectPath -c $Configuration -p:RimWorldPath="$RimWorldPath"
if ($LASTEXITCODE -ne 0) { throw "Build fehlgeschlagen." }

Write-Host "Build erfolgreich. DLL liegt in: $(Join-Path $PSScriptRoot 'Assemblies\AutoDeathRest.dll')"
