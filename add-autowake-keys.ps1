$ErrorActionPreference = "Stop"

# Load translations from a separate UTF-8 JSON file. PowerShell 5.1 reads .ps1
# files as ANSI by default, so embedding non-ASCII string literals here would
# corrupt them. JSON via Get-Content -Encoding UTF8 + ConvertFrom-Json is safe.
$jsonPath = Join-Path $PSScriptRoot "autowake-translations.json"
$translations = Get-Content -Raw -Path $jsonPath -Encoding UTF8 | ConvertFrom-Json

$root = Join-Path $PSScriptRoot "Languages"

function Esc([string]$s) { $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;') }

foreach ($prop in $translations.PSObject.Properties) {
    $lang  = $prop.Name
    $label = $prop.Value.label
    $tip   = $prop.Value.tip

    $file = Join-Path $root "$lang\Keyed\AutoDeathRest.xml"
    if (-not (Test-Path $file)) { Write-Warning "missing: $file"; continue }

    $content = Get-Content -Raw -Path $file -Encoding UTF8

    if ($content -match 'AutoDeathRest\.ForceAutoWake') {
        Write-Output "skip (already has key): $lang"
        continue
    }

    $insert = "  <AutoDeathRest.ForceAutoWake>" + (Esc $label) + "</AutoDeathRest.ForceAutoWake>`r`n" +
              "  <AutoDeathRest.ForceAutoWakeTip>" + (Esc $tip) + "</AutoDeathRest.ForceAutoWakeTip>`r`n"

    $new = $content -replace '(?s)([ \t]*</LanguageData>\s*)$', ($insert + '$1')
    if ($new -eq $content) { Write-Warning "no </LanguageData> match in $lang"; continue }

    [System.IO.File]::WriteAllText($file, $new, (New-Object System.Text.UTF8Encoding $true))
    Write-Output "updated: $lang"
}
