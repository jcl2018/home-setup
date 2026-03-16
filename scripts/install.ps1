param(
  [string]$TargetHome = [Environment]::GetFolderPath("UserProfile"),
  [switch]$WithAutomation
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path -Parent $ScriptRoot
$Templates = Join-Path $Root "templates"
$Manifest = Join-Path $Root "config/reference-paths.tsv"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

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

function Get-RelativeFiles {
  param(
    [object[]]$Entries
  )

  $relativeFiles = [System.Collections.Generic.List[string]]::new()

  foreach ($entry in $Entries) {
    $sourcePath = Join-Path $Templates $entry.RelativePath

    switch ($entry.Kind) {
      "file" {
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
          throw "Missing template file: $sourcePath"
        }
        $relativeFiles.Add($entry.RelativePath)
      }
      "dir" {
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
          throw "Missing template directory: $sourcePath"
        }

        foreach ($file in Get-ChildItem -LiteralPath $sourcePath -Recurse -File -Force | Sort-Object FullName) {
          $relativePath = $file.FullName.Substring($Templates.Length + 1) -replace "\\", "/"
          $relativeFiles.Add($relativePath)
        }
      }
      default {
        throw "Unsupported manifest kind '$($entry.Kind)' for $($entry.RelativePath)"
      }
    }
  }

  $relativeFiles | Sort-Object -Unique
}

$scopes = @("shared")
if ($WithAutomation) {
  $scopes += "automation"
}

$entries = Get-ManifestEntries -Scopes $scopes
$relativeFiles = Get-RelativeFiles -Entries $entries
$normalizedTargetHome = [System.IO.Path]::GetFullPath($TargetHome)
$renderHome = $normalizedTargetHome -replace "\\", "/"
$stageRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("home-setup." + [guid]::NewGuid().ToString("N"))

New-Item -ItemType Directory -Path $stageRoot | Out-Null

try {
  foreach ($relativeFile in $relativeFiles) {
    $sourceFile = Join-Path $Templates $relativeFile
    $stageFile = Join-Path $stageRoot $relativeFile
    $stageParent = Split-Path -Parent $stageFile
    if ($stageParent) {
      New-Item -ItemType Directory -Path $stageParent -Force | Out-Null
    }

    $content = [System.IO.File]::ReadAllText($sourceFile)
    $rendered = $content.Replace("__HOME__", $renderHome)
    [System.IO.File]::WriteAllText($stageFile, $rendered, $Utf8NoBom)
  }

  New-Item -ItemType Directory -Path $normalizedTargetHome -Force | Out-Null

  foreach ($relativeFile in $relativeFiles) {
    $stageFile = Join-Path $stageRoot $relativeFile
    $destinationFile = Join-Path $normalizedTargetHome $relativeFile
    $destinationParent = Split-Path -Parent $destinationFile

    if ($destinationParent) {
      New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
    }

    if (Test-Path -LiteralPath $destinationFile -PathType Leaf) {
      Copy-Item -LiteralPath $destinationFile -Destination ($destinationFile + ".home-setup.bak") -Force
    }

    Copy-Item -LiteralPath $stageFile -Destination $destinationFile -Force
  }
}
finally {
  if (Test-Path -LiteralPath $stageRoot) {
    Remove-Item -LiteralPath $stageRoot -Recurse -Force
  }
}

Write-Output ("Installed {0} portable shared files into {1}" -f $relativeFiles.Count, $normalizedTargetHome)
if ($WithAutomation) {
  Write-Output "Optional automation installed."
} else {
  Write-Output "Optional automation skipped. Re-run with -WithAutomation if you want it."
}
Write-Output "Skipped Unix/mac-only files: .gitconfig, .zprofile, .config/home-setup/secrets.zsh.example"
Write-Output "This Windows bootstrap installs only the portable shared Codex layer."
