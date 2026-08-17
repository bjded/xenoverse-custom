[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [string]$BaseRef,

  [string]$TargetRef = "HEAD",
  [string]$OutputDirectory = "",
  [string]$AssetName = "Xenoverse-update.zip",
  [string]$RepositoryUrl = "https://github.com/bjded/xenoverse-custom",
  [string]$ReleaseTag = "",
  [string]$DownloadUrl = "",
  [switch]$AllowDirty,
  [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$settingsPath = "Xenoverse/Data/Scripts/001_Settings.rb"
$maxPackageBytes = 524288000
$tempRoot = $null
$packagePath = $null
$packageCreated = $false

function Invoke-GitText([string[]]$Arguments) {
  $output = & git "-c" "safe.directory=$repoRoot" @Arguments 2>&1
  if ($LASTEXITCODE -ne 0) {
    $details = ($output | Out-String).Trim()
    throw "git $($Arguments -join ' ') failed. $details"
  }
  return @($output | ForEach-Object { $_.ToString() })
}

function Resolve-GitCommit([string]$Reference) {
  $resolved = @(Invoke-GitText @("rev-parse","--verify",("{0}^{{commit}}" -f $Reference)))
  if ($resolved.Count -ne 1 -or [string]::IsNullOrWhiteSpace($resolved[0])) {
    throw "Could not resolve Git reference '$Reference'."
  }
  return $resolved[0].Trim()
}

function Get-VersionFromCommit([string]$Commit) {
  $showPath = "{0}:{1}" -f $Commit,$settingsPath
  $source = (Invoke-GitText @("show",$showPath)) -join "`n"
  $match = [regex]::Match($source,'GAME_VERSION\s*=\s*Version\.new\("(?<version>[0-9]+(?:\.[0-9]+)+)"\)')
  if (-not $match.Success) {
    throw "Could not read GAME_VERSION from $showPath."
  }
  return $match.Groups["version"].Value
}

function Get-GameRelativePath([string]$RepositoryPath) {
  $normalized = $RepositoryPath.Trim() -replace "\\","/"
  $prefix = "Xenoverse/"
  if (-not $normalized.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) {
    throw "Changed path is outside the game directory: $RepositoryPath"
  }
  $relative = $normalized.Substring($prefix.Length)
  if ([string]::IsNullOrWhiteSpace($relative) -or $relative -match '(^|/)\.\.(/|$)') {
    throw "Unsafe changed path: $RepositoryPath"
  }
  return $relative -replace "/","\"
}

function Test-LocalStatePath([string]$RelativePath) {
  $normalized = $RelativePath -replace "/","\"
  if ($normalized -match '(^|\\)Game(?:_[^\\]+)?\.rxdata(?:\.bak)?$') {
    return $true
  }
  if ($normalized -match '(^|\\)GameSettings\.rxdata$') {
    return $true
  }
  if ($normalized -match '(^|\\)(?:Data\\)?LastSave[^\\]*\.dat$') {
    return $true
  }
  return $false
}

function Get-ChangedRepositoryPaths([string]$BaseCommit,[string]$TargetCommit,[string]$Filter,[bool]$NameOnly) {
  if ($NameOnly) {
    $lines = @(Invoke-GitText @("diff","--name-only","--no-renames","--diff-filter=$Filter",$BaseCommit,$TargetCommit,"--","Xenoverse"))
  } else {
    $lines = @(Invoke-GitText @("diff","--name-status","--no-renames","--diff-filter=$Filter",$BaseCommit,$TargetCommit,"--","Xenoverse"))
  }
  $paths = @(
    foreach ($line in $lines) {
      $text = $line.ToString().Trim()
      if ([string]::IsNullOrWhiteSpace($text)) {
        continue
      }
      if ($NameOnly) {
        $text
      } else {
        $parts = $text -split "`t"
        if ($parts.Count -lt 2) {
          throw "Could not parse Git path: $text"
        }
        $parts[$parts.Count-1]
      }
    }
  )
  return @($paths | Sort-Object -Unique)
}

try {
  if (-not (Test-Path -LiteralPath (Join-Path $repoRoot ".git") -PathType Container)) {
    throw "The repository root could not be located at $repoRoot."
  }

  $dirty = @(Invoke-GitText @("status","--porcelain=v1","--","Xenoverse"))
  if ($dirty.Count -gt 0 -and -not $AllowDirty) {
    throw "The Xenoverse working tree has uncommitted changes. Commit them first, or pass -AllowDirty to package the committed target ref."
  }

  $baseCommit = Resolve-GitCommit $BaseRef
  $targetCommit = Resolve-GitCommit $TargetRef
  if ($baseCommit -eq $targetCommit) {
    throw "BaseRef and TargetRef resolve to the same commit."
  }

  $baseVersion = Get-VersionFromCommit $baseCommit
  $targetVersion = Get-VersionFromCommit $targetCommit
  try {
    $baseVersionObject = [Version]$baseVersion
    $targetVersionObject = [Version]$targetVersion
  } catch {
    throw "The game versions '$baseVersion' and '$targetVersion' are not valid release versions."
  }
  if ($targetVersionObject -le $baseVersionObject) {
    throw "Target version $targetVersion must be newer than base version $baseVersion."
  }

  $changedPaths = Get-ChangedRepositoryPaths $baseCommit $targetCommit "ACMR" $false
  $deletedPaths = Get-ChangedRepositoryPaths $baseCommit $targetCommit "D" $true
  $includedPaths = @()
  foreach ($path in $changedPaths) {
    $relative = Get-GameRelativePath $path
    if (-not (Test-LocalStatePath $relative)) {
      $includedPaths += $path
    }
  }
  $deletedRelativePaths = @()
  foreach ($path in $deletedPaths) {
    $relative = Get-GameRelativePath $path
    if (-not (Test-LocalStatePath $relative)) {
      $deletedRelativePaths += $relative
    }
  }
  $includedPaths = @($includedPaths | Sort-Object -Unique)
  $deletedRelativePaths = @($deletedRelativePaths | Sort-Object -Unique)
  if ($includedPaths.Count -eq 0 -and $deletedRelativePaths.Count -eq 0) {
    throw "No applicable Xenoverse files changed between $BaseRef and $TargetRef."
  }
  if ($baseVersion -ne $targetVersion -and $includedPaths -notcontains $settingsPath) {
    throw "$settingsPath did not change even though the game version changed from $baseVersion to $targetVersion."
  }

  if ([string]::IsNullOrWhiteSpace($AssetName) -or [IO.Path]::GetFileName($AssetName) -ne $AssetName -or [IO.Path]::GetExtension($AssetName).ToLowerInvariant() -ne ".zip") {
    throw "AssetName must be a ZIP filename without directory separators."
  }

  $RepositoryUrl = $RepositoryUrl.TrimEnd("/")
  if ([string]::IsNullOrWhiteSpace($ReleaseTag)) {
    $ReleaseTag = "v$targetVersion"
  }
  if ([string]::IsNullOrWhiteSpace($DownloadUrl)) {
    $DownloadUrl = "$RepositoryUrl/releases/download/$ReleaseTag/$AssetName"
  }
  $releasePageUrl = "$RepositoryUrl/releases/tag/$ReleaseTag"
  if ($DownloadUrl -notmatch '^https://') {
    throw "DownloadUrl must use HTTPS."
  }

  if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $repoRoot "dist\updates\v$targetVersion"
  } elseif (-not [IO.Path]::IsPathRooted($OutputDirectory)) {
    $OutputDirectory = Join-Path $repoRoot $OutputDirectory
  }
  $resolvedOutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
  $packagePath = Join-Path $resolvedOutputDirectory $AssetName
  $manifestPath = Join-Path $resolvedOutputDirectory "UpdateManifest.txt"
  $hashPath = "$packagePath.sha256"
  $outputPaths = @($packagePath,$manifestPath,$hashPath)
  if (-not $Force) {
    foreach ($outputPath in $outputPaths) {
      if (Test-Path -LiteralPath $outputPath) {
        throw "Output already exists: $outputPath. Use -Force to replace generated artifacts."
      }
    }
  } else {
    foreach ($outputPath in $outputPaths) {
      if (Test-Path -LiteralPath $outputPath) {
        Remove-Item -LiteralPath $outputPath -Force
      }
    }
  }

  $tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("xenoverse-update-build-" + [Guid]::NewGuid().ToString("N"))
  $stagingRoot = Join-Path $tempRoot "staging"
  $sourceArchive = Join-Path $tempRoot "source.zip"
  New-Item -ItemType Directory -Path $stagingRoot -Force | Out-Null

  if ($includedPaths.Count -gt 0) {
    $archiveArguments = @("archive","--format=zip","--output=$sourceArchive",$targetCommit,"--") + $includedPaths
    $archiveOutput = & git "-c" "safe.directory=$repoRoot" @archiveArguments 2>&1
    if ($LASTEXITCODE -ne 0) {
      $details = ($archiveOutput | Out-String).Trim()
      throw "Could not create the Git source archive. $details"
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [IO.Compression.ZipFile]::ExtractToDirectory($sourceArchive,$stagingRoot)
  } else {
    New-Item -ItemType Directory -Path (Join-Path $stagingRoot "Xenoverse") -Force | Out-Null
  }

  if ($deletedRelativePaths.Count -gt 0) {
    $metadataDirectory = Join-Path $stagingRoot "Xenoverse\.xenoverse-update"
    New-Item -ItemType Directory -Path $metadataDirectory -Force | Out-Null
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $deletionText = ($deletedRelativePaths -join "`r`n") + "`r`n"
    [IO.File]::WriteAllText((Join-Path $metadataDirectory "deletions.txt"),$deletionText,$utf8NoBom)
  }

  New-Item -ItemType Directory -Path $resolvedOutputDirectory -Force | Out-Null
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [IO.Compression.ZipFile]::CreateFromDirectory($stagingRoot,$packagePath,[IO.Compression.CompressionLevel]::Optimal,$false)
  $packageCreated = $true
  $packageInfo = Get-Item -LiteralPath $packagePath
  if ($packageInfo.Length -gt $maxPackageBytes) {
    throw "The generated package is $($packageInfo.Length) bytes, above the updater limit of $maxPackageBytes bytes."
  }

  $hash = (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToLowerInvariant()
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [IO.File]::WriteAllText($hashPath,"$hash  $AssetName`r`n",$utf8NoBom)
  $manifestText = @(
    "# Generated by tools/Build-XenoverseUpdate.ps1",
    "version=$targetVersion",
    "url=$releasePageUrl",
    "download=$DownloadUrl"
  ) -join "`r`n"
  [IO.File]::WriteAllText($manifestPath,"$manifestText`r`n",$utf8NoBom)

  Write-Host "Built $packagePath"
  Write-Host ("Base: {0} ({1})" -f $BaseRef,$baseVersion)
  Write-Host ("Target: {0} ({1})" -f $TargetRef,$targetVersion)
  Write-Host ("Included files: {0}; deleted files: {1}" -f $includedPaths.Count,$deletedRelativePaths.Count)
  Write-Host "Manifest: $manifestPath"
  Write-Host "SHA-256: $hashPath"
} catch {
  if ($packageCreated -and $packagePath -and (Test-Path -LiteralPath $packagePath)) {
    Remove-Item -LiteralPath $packagePath -Force -ErrorAction SilentlyContinue
  }
  throw
} finally {
  if ($tempRoot -and (Test-Path -LiteralPath $tempRoot)) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}
