# Run RouteWise on local web server (internal testing).
# Usage: .\script\run_web.ps1 [-Port 8080] [-MapsApiKey "..."] [-MapboxToken "..."]
param(
    [int]$Port = 8080,
    [string]$MapsApiKey = $env:MAPS_API_KEY,
    [string]$MapboxToken = $env:MAPBOX_ACCESS_TOKEN
)

Set-Location (Join-Path $PSScriptRoot "..")

$defines = @()
if ($MapsApiKey) { $defines += "MAPS_API_KEY=$MapsApiKey" }
if ($MapboxToken) { $defines += "MAPBOX_ACCESS_TOKEN=$MapboxToken" }

$dartDefineArgs = $defines | ForEach-Object { "--dart-define=$_" }

flutter run -d web-server --web-port=$Port --web-hostname=localhost @dartDefineArgs
