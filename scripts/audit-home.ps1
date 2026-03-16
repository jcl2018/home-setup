param(
  [string]$TargetHome = [Environment]::GetFolderPath("UserProfile")
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path -Parent $ScriptRoot
$Templates = Join-Path $Root "templates"
$Manifest = Join-Path $Root "config/reference-paths.tsv"
$NormalizedTargetHome = [System.IO.Path]::GetFullPath($TargetHome)
$script:PresentCount = 0
$script:MissingCount = 0

function Write-Status {
  param(
    [string]$Status,
    [string]$RelativePath,
    [string]$Note
  )

  switch ($Status) {
    "present" { $script:PresentCount++ }
    "missing" { $script:MissingCount++ }
  }

  Write-Output ("[{0}]  {1,-58} {2}" -f $Status, $RelativePath, $Note)
}

function Write-Info {
  param(
    [string]$RelativePath,
    [string]$Note
  )

  Write-Output ("[info]  {0,-58} {1}" -f $RelativePath, $Note)
}

function Test-RelativePath {
  param(
    [string]$RelativePath,
    [string]$Note
  )

  $fullPath = Join-Path $NormalizedTargetHome $RelativePath
  if (Test-Path -LiteralPath $fullPath) {
    Write-Status -Status "present" -RelativePath $RelativePath -Note $Note
  } else {
    Write-Status -Status "missing" -RelativePath $RelativePath -Note $Note
  }
}

function Test-RelativeGlob {
  param(
    [string]$RelativeGlob,
    [string]$Note
  )

  $matches = Get-ChildItem -Path (Join-Path $NormalizedTargetHome $RelativeGlob) -ErrorAction SilentlyContinue
  if ($matches) {
    Write-Status -Status "present" -RelativePath $RelativeGlob -Note $Note
  } else {
    Write-Status -Status "missing" -RelativePath $RelativeGlob -Note $Note
  }
}

function Get-ManifestEntries {
  param(
    [string[]]$Scopes
  )

  $scopeSet = @{}
  foreach ($scope in $Scopes) {
    $scopeSet[$scope] = $true
  }

  foreach ($line in Get-Content -LiteralPath $Manifest) {
    if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) {
      continue
    }

    $parts = $line -split "`t", 4
    if ($parts.Count -lt 4) {
      throw "Invalid manifest entry: $line"
    }

    if (-not $scopeSet.ContainsKey($parts[0])) {
      continue
    }

    [pscustomobject]@{
      Scope = $parts[0]
      Kind = $parts[1]
      RelativePath = $parts[2]
      Note = $parts[3]
    }
  }
}

function Get-ManifestFiles {
  param(
    [object]$Entry
  )

  $sourcePath = Join-Path $Templates $Entry.RelativePath

  switch ($Entry.Kind) {
    "file" {
      if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        throw "Missing template file: $sourcePath"
      }
      return @($Entry.RelativePath)
    }
    "dir" {
      if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
        throw "Missing template directory: $sourcePath"
      }

      return @(Get-ChildItem -LiteralPath $sourcePath -Recurse -File -Force |
        Sort-Object FullName |
        ForEach-Object { $_.FullName.Substring($Templates.Length + 1) -replace "\\", "/" })
    }
    default {
      throw "Unsupported manifest kind '$($Entry.Kind)' for $($Entry.RelativePath)"
    }
  }
}

function Test-ManifestScopes {
  param(
    [string[]]$Scopes
  )

  foreach ($entry in Get-ManifestEntries -Scopes $Scopes) {
    foreach ($relativeFile in Get-ManifestFiles -Entry $entry) {
      Test-RelativePath -RelativePath $relativeFile -Note $entry.Note
    }
  }
}

if (-not (Test-Path -LiteralPath $NormalizedTargetHome -PathType Container)) {
  throw "Target home does not exist: $NormalizedTargetHome"
}

Write-Output "Home setup audit"
Write-Output ("Target home: {0}" -f $NormalizedTargetHome)
Write-Output ""
Write-Output "Portable shared reference items"
Test-ManifestScopes -Scopes @("shared")
Write-Output ""
Write-Output "Optional automation"
Test-ManifestScopes -Scopes @("automation")
Write-Output ""
Write-Output "Unix/mac reference items intentionally skipped by the Windows flow"
foreach ($entry in Get-ManifestEntries -Scopes @("unix")) {
  Write-Info -RelativePath $entry.RelativePath -Note $entry.Note
}
Write-Output ""
Write-Output "Environment-provided and not managed by this repo"
Test-RelativePath -RelativePath ".codex/skills/.system/openai-docs/SKILL.md" -Note "visible bundled skill when provided by Codex"
Test-RelativePath -RelativePath ".codex/skills/.system/skill-creator/SKILL.md" -Note "visible bundled skill when provided by Codex"
Test-RelativePath -RelativePath ".codex/skills/.system/skill-installer/SKILL.md" -Note "visible bundled skill when provided by Codex"
Write-Output ""
Write-Output "Local-only and intentionally not managed by this repo"
Test-RelativePath -RelativePath ".codex/auth.json" -Note "local Codex sign-in state"
Test-RelativeGlob -RelativeGlob ".codex/logs_*.sqlite*" -Note "local Codex log database"
Test-RelativeGlob -RelativeGlob ".codex/state_*.sqlite*" -Note "local Codex state database"
Test-RelativePath -RelativePath ".codex/models_cache.json" -Note "local Codex model cache"
Test-RelativePath -RelativePath ".codex/sessions" -Note "local Codex session history"
Test-RelativePath -RelativePath ".codex/shell_snapshots" -Note "local Codex shell snapshots"
Write-Output ""
Write-Output ("Summary: {0} present, {1} missing" -f $script:PresentCount, $script:MissingCount)
Write-Output "Missing portable shared items are duplication candidates."
Write-Output "Missing local-only items are usually fine until that machine needs them."
