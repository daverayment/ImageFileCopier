# Image File Mover

## Introduction
This is a small PowerShell script to help clean up and move image files (such as those from ImageFX) between folders on your PC.

I created it to solve recurring issues with inconsistent file naming on device and frustrating copy behavior in Windows Explorer.

This will likely be replaced at some point by [My Copy-MTPFiles script](https://github.com/daverayment/Copy-MTPFiles). But not today.

## The Problem

### 1. **Broken Naming Conventions**
AI image apps often save every image with the same filename, e.g. `image_fx.jpg` for...er, ImageFX. On Android, this can lead to:

  - The first 100 files being called `image_fx (n).jpg` - fine.
  - Some files (for some reason I can't comprehend) called `image_fx.jpg (n)` - these **lack a valid extension**, and Windows won't treat them as images.
  - Eventually (usually), the device comes up with a better format: `image_fx - [timestamp].jpg`, where `[timestamp]` is the to-the-microsecond time the file was saved. Finally, something unique!

  This chaotic naming means manually sorting images after transferring them to PC is slow and painful.

### 2. **Windows Explorer Conflict Handling**

Copying these files with Windows Explorer sounds easy, until you actually try:

- **From MTP devices (like your phone):**
  - Explorer will ask you what you want to do **only once** when it encounters the first filename conflict.
  - You can "Apply this action to the next N files" (where N can be...lots), but if you don't, the rest silently fail to copy.
  - There's no global "Keep both and rename", so you either have to overwrite all, skip all, or give up and copy the files to a new location.

- **From PC to PC (local drive transfers)**
  - Explorer will prompt for **every single conflict**, unless you opt to apply one action.
  - There is no "Keep both and rename" option for all files.

## What This Script Does

This script is intentionally minimal (or, if you will, **compact and efficient**). It:

- Normalises badly named `image_fx` files by adding a timestamp if one is missing.
- Fixing incorrectly formed filenames like `ai_image.jpg (n)`.
- Moves (or simulates moving, if `-DryRun` is set) all valid image files to the target folder.
- Automatically resolves filename conflicts by appending a numeric suffix.
- Skips files with non-image extensions.
- Never overwrites existing files.

## Supported Formats
The script currently recognises files with these extensions as images:

- `.jpg`, `.jpeg`, `.png`, `.webp`, `.bmp`, `.gif`, `.tiff`

Edit the script if you want to add more extensions.

## Usage

```powershell
.\RenameAndMove.ps1 -Source "C:\Path\To\Images" -Target "C:\SortedImages"
```

### Optional Parameters

- `-DryRun`: Simulates the actions without moving any of the files.
- `-Help`: Displays usage information.

### Example (Dry Run)
``` powershell
.\RenameAndMove.ps1 . results -DryRun  # Move from current directory to .\results
```

## Requirements
- PowerShell 5.1+ (Windows 10 and later)

## Notes
- This was written for personal use, but hopefully it may be useful for others trying to contend with AI image generation chaos.
- No depdendencies.

## Future Ideas
- Support videos?
- Option to copy instead of move.

## Licence
- [MIT](LICENSE)