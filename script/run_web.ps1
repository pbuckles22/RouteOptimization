# Run RouteWise for internal web testing (opens Chrome by default).
# Loads .env, starts Google Places proxy, then Flutter.
# Usage: .\script\run_web.ps1 [-Port 8080] [-ServerOnly] [-NoProxy]
param(
    [int]$Port = 8080,
    [switch]$ServerOnly,
    [switch]$NoProxy,
    [string]$MapsApiKey,
    [string]$MapboxToken
)

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $root

$envFile = Join-Path $root ".env"
$extraDefines = @()

if (Test-Path $envFile) {
    $raw = Get-Content $envFile -Raw
    if ($raw.Length -gt 0 -and [int][char]$raw[0] -eq 0xFEFF) {
        $raw = $raw.Substring(1)
    }
    $raw -split "`n" | ForEach-Object {
        $line = $_.Trim()
        if ($line -eq '' -or $line.StartsWith('#')) { return }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { return }
        $name = $line.Substring(0, $eq).Trim()
        $value = $line.Substring($eq + 1).Trim()
        if (
            ($value.StartsWith('"') -and $value.EndsWith('"')) -or
            ($value.StartsWith("'") -and $value.EndsWith("'"))
        ) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        Set-Item -Path "env:$name" -Value $value
        if ($name -eq 'SEARCH_COUNTRY' -and $value) {
            $extraDefines += "--dart-define=SEARCH_COUNTRY=$value"
        }
        if ($name -eq 'SEARCH_PROXIMITY_LNG' -and $value) {
            $extraDefines += "--dart-define=SEARCH_PROXIMITY_LNG=$value"
        }
        if ($name -eq 'SEARCH_PROXIMITY_LAT' -and $value) {
            $extraDefines += "--dart-define=SEARCH_PROXIMITY_LAT=$value"
        }
    }
}

if (-not $MapsApiKey) { $MapsApiKey = $env:MAPS_API_KEY }
if (-not $MapboxToken) { $MapboxToken = $env:MAPBOX_ACCESS_TOKEN }

if (-not $MapsApiKey -or -not $MapboxToken) {
    Write-Error "Missing MAPS_API_KEY or MAPBOX_ACCESS_TOKEN in .env"
    exit 1
}

if (-not $NoProxy) {
    $env:MAPS_API_KEY = $MapsApiKey
    Write-Host "Starting Google Places proxy (port 8765)..."
    Start-Process -WindowStyle Minimized `
        -FilePath "dart" `
        -ArgumentList "run", "tool/places_proxy.dart" `
        -WorkingDirectory $root | Out-Null
    Start-Sleep -Seconds 2
}

$dartDefineArgs = @(
    "--dart-define=MAPS_API_KEY=$MapsApiKey",
    "--dart-define=MAPBOX_ACCESS_TOKEN=$MapboxToken"
) + $extraDefines

$device = if ($ServerOnly) { 'web-server' } else { 'chrome' }

Write-Host "Starting RouteWise on http://localhost:$Port ($device)..."
flutter run -d $device --web-port=$Port --web-hostname=localhost @dartDefineArgs
