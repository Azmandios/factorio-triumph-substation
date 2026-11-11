[CmdletBinding()]
param(
    [string]$Version = ""
)

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$info = Get-Content (Join-Path $root "info.json") -Raw | ConvertFrom-Json

if (-not $Version) { $Version = $info.version }
$name = $info.name

$entries = @("info.json", "changelog.txt", "control.lua", "data.lua", "graphics", "locale", "migrations", "prototypes")
$optional = @("README.md", "LICENSE")

$dist = Join-Path $root "dist"
$stage = Join-Path $dist "$($name)_$Version"
$zip = Join-Path $dist "$($name)_$Version.zip"

if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
if (Test-Path $zip) { Remove-Item $zip -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

foreach ($entry in $entries) {
    $source = Join-Path $root $entry
    if (-not (Test-Path $source)) { throw "Не найден обязательный элемент: $entry" }
    Copy-Item $source -Destination $stage -Recurse
}

foreach ($entry in $optional) {
    $source = Join-Path $root $entry
    if (Test-Path $source) { Copy-Item $source -Destination $stage -Recurse }
}

Compress-Archive -Path $stage -DestinationPath $zip -CompressionLevel Optimal

Write-Host "Собрано: $zip"
