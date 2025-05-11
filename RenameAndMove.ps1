param (
    [string]$Source,
    [string]$Target,
    [switch]$DryRun,
    [switch]$Help
)

function Show-Usage {
    Write-Host @"

Image File Normaliser and Mover
===============================

Scans a folder for image files, renames any 'image_fx' files lacking timestamps, and
moves all recognised image files to a destination folder, handling filename collisions.

Usage: RenameAndCopy.ps1 -Source <source folder> -Target <target folder> [-DryRun] [-Help]

Parameters:
  -Source  Source folder to copy from (required)
  -Target  Target folder to copy to (required)
  -DryRun  Show what would be done without making changes
  -Help    Show this help

Examples:
  .\RenameAndCopy.ps1 -Source "C:\Users\me\Pictures" -Target "C:\SortedPictures"
  .\RenameAndCopy.ps1 . results

"@
    exit
}

if ($Help) {
    Show-Usage
    return
}


# Counters
$RenamedCount = 0
$MovedCount = 0
$SkippedCount = 0
$FailedMoveCount = 0

# Ensure target exists
if (!(Test-Path $Target)) {
    if ($DryRun) {
        Write-Host "[DryRun] Would create folder: $Target"
    } else {
        New-Item -ItemType Directory -Path $Target
    }
}

$imageExtensions = @(".jpg", ".jpeg", ".png", ".webp", ".bmp", ".gif", ".tiff")

# Move all image files, normalizing names if needed, and resolving conflicts
Get-ChildItem -Path $Source -File | ForEach-Object {
    $sourceFile = $_
    $originalName = $_.Name

    $realExtension = $_.Extension
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

    # Fix wrongly formed image_fx.jpg (nnn) files
    if ($originalName -match '^image_fx\.(jpg|jpeg) \(\d+\)$') {
        $realExtension = ".$($Matches[1])"
        $baseName = "image_fx"
    }

    if ($imageExtensions -notcontains $realExtension) {
        # Skip files with no extension match
        $SkippedCount++
        return
    }

    # Normalise image_fx filenames to always include timestamp only if not already formatted
    if ($baseName -like "image_fx*") {
        if ($baseName -notmatch "^image_fx - \d{4}-\d{2}-\d{2}T\d{6}\.\d{3}$") {   
            $timestamp = $_.LastWriteTime.ToString("yyyy-MM-ddTHHmmss.fff")
            $baseName = "image_fx - $timestamp"
            $RenamedCount++
        }
    }

    $targetName = "$baseName$realExtension"
    $destPath = Join-Path $Target $targetName

    # Handle name collisions
    if (Test-Path $destPath) {
        $counter = 1
        do {
            $targetName = "$baseName [$counter]$realExtension"
            $destPath = Join-Path $Target $targetName
            $counter++
        } while (Test-Path $destPath)
    }

    try {
        if ($DryRun) {
            Write-Host "[DryRun] Would move '$originalName' → '$(Split-Path $destPath -Leaf)'"
        } else {
            Move-Item $sourceFile.FullName -Destination $destPath
            Write-Host "Moved '$originalName' → '$(Split-Path $destPath -Leaf)'"
        }
        $MovedCount++
    } catch {
        Write-Warning "Failed to move '$originalName' → '$destPath': $_"
        $FailedMoveCount++
    }
}

# Summary
Write-Host ""
Write-Host "=== Summary ==="
if ($DryRun) { Write-Host "(Dry-Run - no changes made)" }
Write-Host "image_fx files timestamp-renamed: $RenamedCount"
Write-Host "Files moved: $MovedCount"
Write-Host "Files failed to move: $FailedMoveCount"
Write-Host "Files skipped: $SkippedCount"
