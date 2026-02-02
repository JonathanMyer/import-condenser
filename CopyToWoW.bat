@echo off

set "SOURCE_DIR=%~dp0"
set "TOC_FILE=%SOURCE_DIR%ImportCondenser\ImportCondenser.toc"

echo Updating TOC addon file list...
powershell -ExecutionPolicy Bypass -File "%SOURCE_DIR%GenerateToc.ps1" -AddonDir "%SOURCE_DIR%ImportCondenser" -TocFile "%TOC_FILE%"

xcopy "ImportCondenser" "C:\Program Files (x86)\World of Warcraft\_ptr_\Interface\AddOns\ImportCondenser" /s /y /i
xcopy "ImportCondenser" "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\ImportCondenser" /s /y /i