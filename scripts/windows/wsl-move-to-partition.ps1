# Run in an elevated (Administrator) PowerShell.
#
# Prerequisite (manual, destructive — done ahead of time via Disk Management /
# diskmgmt.msc): shrink an existing volume and create a new partition with a
# drive letter (e.g. D:) to host WSL. This script does NOT touch partitions;
# it only moves an already-installed WSL distro's virtual disk onto one.
#
# Usage:
#   .\wsl-move-to-partition.ps1 -DistroName Ubuntu -TargetDrive D:\WSL

param(
    [string]$DistroName = "Ubuntu",
    [string]$TargetDrive = "D:\WSL"
)

$ErrorActionPreference = "Stop"
$exportDir = Join-Path $TargetDrive "_export"
$exportFile = Join-Path $exportDir "$DistroName.tar"
$installDir = Join-Path $TargetDrive $DistroName

wsl --shutdown

New-Item -ItemType Directory -Force -Path $exportDir | Out-Null
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

Write-Host "Exporting $DistroName to $exportFile ..."
wsl --export $DistroName $exportFile

Write-Host "Unregistering the default-location copy of $DistroName ..."
wsl --unregister $DistroName

Write-Host "Re-importing $DistroName into $installDir ..."
wsl --import $DistroName $installDir $exportFile --version 2

Remove-Item $exportFile -Force

Write-Host "Done. Launch with: wsl -d $DistroName"
