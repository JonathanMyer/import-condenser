param(
    [Parameter(Mandatory = $false)]
    [string]$AddonDir = (Join-Path $PSScriptRoot 'ImportCondenser'),

    [Parameter(Mandatory = $false)]
    [string]$TocFile = (Join-Path (Join-Path $PSScriptRoot 'ImportCondenser') 'ImportCondenser.toc')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-AddonLuaLine {
    param([string]$Line)

    if ($null -eq $Line) { return $false }
    $trimmed = $Line.Trim()
    return ($trimmed -match '^(?i:addons)[\\/].+\.lua$')
}

$resolvedAddonDir = (Resolve-Path -LiteralPath $AddonDir).Path
$resolvedTocFile = (Resolve-Path -LiteralPath $TocFile).Path

$addonsDir = Join-Path $resolvedAddonDir 'addons'
if (-not (Test-Path -LiteralPath $addonsDir -PathType Container)) {
    throw "Addons folder not found: $addonsDir"
}

$tocLines = Get-Content -LiteralPath $resolvedTocFile
if ($tocLines.Count -eq 0) {
    throw "TOC file is empty: $resolvedTocFile"
}

$addonCodeHeaderIndex = -1
for ($i = 0; $i -lt $tocLines.Count; $i++) {
    if ($tocLines[$i].Trim() -eq '# Addon code') {
        $addonCodeHeaderIndex = $i
        break
    }
}

if ($addonCodeHeaderIndex -lt 0) {
    throw "Could not find '# Addon code' marker in: $resolvedTocFile"
}

$existingStartIndex = -1
for ($i = $addonCodeHeaderIndex + 1; $i -lt $tocLines.Count; $i++) {
    if (Test-AddonLuaLine -Line $tocLines[$i]) {
        $existingStartIndex = $i
        break
    }
}

$existingEndIndex = -1
if ($existingStartIndex -ge 0) {
    $existingEndIndex = $existingStartIndex
    for ($i = $existingStartIndex + 1; $i -lt $tocLines.Count; $i++) {
        if (Test-AddonLuaLine -Line $tocLines[$i]) {
            $existingEndIndex = $i
            continue
        }
        break
    }
}

$addonFiles = Get-ChildItem -LiteralPath $addonsDir -Filter '*.lua' -File -Recurse |
    Sort-Object FullName

$generatedAddonLines = foreach ($file in $addonFiles) {
    $relative = $file.FullName.Substring($addonsDir.Length).TrimStart('\', '/')
    $relative = $relative -replace '\\', '/'
    "addons/$relative"
}

# If there was no existing addon block, insert at end of file.
if ($existingStartIndex -lt 0) {
    $newLines = @()
    $newLines += $tocLines
    if ($newLines.Count -gt 0 -and $newLines[$newLines.Count - 1] -ne '') {
        # keep a trailing newline in a predictable way
        # (Set-Content will add its own line ending)
    }
    $newLines += $generatedAddonLines
}
else {
    $before = @()
    if ($existingStartIndex -gt 0) {
        $before = $tocLines[0..($existingStartIndex - 1)]
    }

    $after = @()
    if ($existingEndIndex -lt ($tocLines.Count - 1)) {
        $after = $tocLines[($existingEndIndex + 1)..($tocLines.Count - 1)]
    }

    $newLines = @()
    $newLines += $before
    $newLines += $generatedAddonLines
    $newLines += $after
}

Set-Content -LiteralPath $resolvedTocFile -Value $newLines -Encoding UTF8

Write-Host "Updated TOC addon list: $resolvedTocFile" -ForegroundColor Green
Write-Host ("Found {0} addon lua files under: {1}" -f $generatedAddonLines.Count, $addonsDir)
