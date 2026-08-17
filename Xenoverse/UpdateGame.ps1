param(
  [Parameter(Mandatory=$true)][string]$GameDirectory,
  [Parameter(Mandatory=$true)][string]$PackagePath,
  [Parameter(Mandatory=$true)][int]$ProcessId,
  [Parameter(Mandatory=$true)][string]$GameExecutable
)

$ErrorActionPreference = "Stop"
$gameRoot = [IO.Path]::GetFullPath($GameDirectory).TrimEnd('\')
$package = [IO.Path]::GetFullPath($PackagePath)
$gameExe = [IO.Path]::GetFullPath($GameExecutable)
$stageRoot = $null
$backupRoot = $null
$backups = @{}
$copied = @()

function Write-UpdateLog([string]$Message) {
  try {
    Add-Content -LiteralPath (Join-Path $gameRoot "UpdateGame.log") -Value ("{0} {1}" -f (Get-Date).ToString("s"),$Message)
  } catch {
  }
}

function Test-UpdateRoot([string]$Path) {
  return (Test-Path -LiteralPath (Join-Path $Path "Game.ini") -PathType Leaf) -or
    (Test-Path -LiteralPath (Join-Path $Path "Data") -PathType Container)
}

function Test-PreservedPath([string]$RelativePath) {
  $normalized = $RelativePath -replace "/","\"
  if ($normalized -match '(^|\\)Game(?:_[^\\]+)?\.rxdata(?:\.bak)?$') {
    return $true
  }
  if ($normalized -match '(^|\\)GameSettings\.rxdata$') {
    return $true
  }
  if ($normalized -match '^Data\\LastSave[^\\]*\.dat$') {
    return $true
  }
  return $false
}

function Get-SafeDestination([string]$RelativePath) {
  $candidate = [IO.Path]::GetFullPath((Join-Path $gameRoot $RelativePath))
  $rootPrefix = $gameRoot + '\'
  if (-not $candidate.StartsWith($rootPrefix,[StringComparison]::OrdinalIgnoreCase)) {
    throw "Update path escapes the game directory: $RelativePath"
  }
  return $candidate
}

try {
  if (-not (Test-Path -LiteralPath $gameRoot -PathType Container)) {
    throw "Game directory does not exist"
  }
  if (-not (Test-Path -LiteralPath (Join-Path $gameRoot "Game.ini") -PathType Leaf)) {
    throw "Game directory validation failed"
  }
  if (-not (Test-Path -LiteralPath $package -PathType Leaf)) {
    throw "Downloaded update package does not exist"
  }

  $deadline = [DateTime]::UtcNow.AddSeconds(60)
  while ($true) {
    $running = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    if (-not $running) {
      break
    }
    if ([DateTime]::UtcNow -ge $deadline) {
      throw "The game process did not exit in time"
    }
    Start-Sleep -Milliseconds 250
  }

  $stageRoot = Join-Path ([IO.Path]::GetTempPath()) ("xenoverse-update-" + [Guid]::NewGuid().ToString("N"))
  $packageRoot = Join-Path $stageRoot "package"
  $backupRoot = Join-Path $stageRoot "backup"
  New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null
  New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

  Expand-Archive -LiteralPath $package -DestinationPath $packageRoot -Force
  $sourceRoot = $packageRoot
  $nestedRoot = Join-Path $packageRoot "Xenoverse"
  if (Test-UpdateRoot $nestedRoot) {
    $sourceRoot = $nestedRoot
  } else {
    $topDirectories = @(Get-ChildItem -LiteralPath $packageRoot -Directory -Force)
    if ($topDirectories.Count -eq 1) {
      $topDirectory = $topDirectories[0].FullName
      $repositoryGameRoot = Join-Path $topDirectory "Xenoverse"
      if (Test-UpdateRoot $repositoryGameRoot) {
        $sourceRoot = $repositoryGameRoot
      } elseif (Test-UpdateRoot $topDirectory) {
        $sourceRoot = $topDirectory
      }
    }
  }
  $sourceRoot = [IO.Path]::GetFullPath($sourceRoot).TrimEnd('\')

  $plan = @()
  $files = @(Get-ChildItem -LiteralPath $sourceRoot -Recurse -File -Force)
  foreach ($file in $files) {
    $relative = $file.FullName.Substring($sourceRoot.Length).TrimStart([char[]]"\/")
    if ([string]::IsNullOrEmpty($relative) -or (Test-PreservedPath $relative)) {
      continue
    }
    $destination = Get-SafeDestination $relative
    $plan += New-Object PSObject -Property @{
      Source = $file.FullName
      Relative = $relative
      Destination = $destination
    }
  }
  if ($plan.Count -eq 0) {
    throw "The update package contained no applicable files"
  }

  foreach ($item in $plan) {
    if (Test-Path -LiteralPath $item.Destination -PathType Leaf) {
      $backupPath = Join-Path $backupRoot $item.Relative
      $backupParent = Split-Path -Parent $backupPath
      New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
      Copy-Item -LiteralPath $item.Destination -Destination $backupPath -Force
      $backups[$item.Destination] = $backupPath
    }
  }

  foreach ($item in $plan) {
    $destinationParent = Split-Path -Parent $item.Destination
    New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
    Copy-Item -LiteralPath $item.Source -Destination $item.Destination -Force
    $copied += $item.Destination
  }

  Start-Process -FilePath $gameExe -WorkingDirectory $gameRoot
  Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue
  $success = $true
  Write-UpdateLog "Update applied successfully."
} catch {
  Write-UpdateLog ("Update failed: " + $_.Exception.Message)
  for ($i=$copied.Count-1; $i -ge 0; $i--) {
    $destination = $copied[$i]
    try {
      if ($backups.ContainsKey($destination)) {
        Copy-Item -LiteralPath $backups[$destination] -Destination $destination -Force
      } elseif (Test-Path -LiteralPath $destination -PathType Leaf) {
        Remove-Item -LiteralPath $destination -Force
      }
    } catch {
    }
  }
} finally {
  if ($stageRoot -and (Test-Path -LiteralPath $stageRoot)) {
    Remove-Item -LiteralPath $stageRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}
