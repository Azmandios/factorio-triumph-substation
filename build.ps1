[CmdletBinding()]
param(
    [string]$Version = "2.1.0"
)

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$source = Join-Path $root "src\TriumphSubstation_$Version"
$dist = Join-Path $root "dist"
$zip = Join-Path $dist "TriumphSubstation_$Version.zip"

if (-not (Test-Path $source)) {
    throw "Source directory not found: $source"
}

New-Item -ItemType Directory -Force -Path $dist | Out-Null
if (Test-Path $zip) {
    Remove-Item $zip -Force
}

Compress-Archive -Path $source -DestinationPath $zip -CompressionLevel Optimal

Write-Host "Created $zip"
