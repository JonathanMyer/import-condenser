@echo off
setlocal enabledelayedexpansion

:: Get the parent directory and folder name
set "FOLDER_NAME=ImportCondenser"
set "SOURCE_DIR=%~dp0"
set "TOC_FILE=%SOURCE_DIR%ImportCondenser\ImportCondenser.toc"

:: Read current version from .toc file
for /f "tokens=3" %%v in ('findstr /C:"## Version:" "%TOC_FILE%"') do set "CURRENT_VERSION=%%v"

echo Current version in .toc: %CURRENT_VERSION%
echo.

:: Parse version (assuming format x.y)
for /f "tokens=1,2 delims=." %%a in ("%CURRENT_VERSION%") do (
    set "MAJOR=%%a"
    set "MINOR=%%b"
)

:: Ask user for version bump type
echo What type of version bump?
echo [1] Major (%MAJOR%.x)
echo [2] Minor (x.%MINOR%)
echo.
set /p BUMP_TYPE="Enter choice (1-2): "

:: Increment version based on choice
if "%BUMP_TYPE%"=="1" (
    set /a "MAJOR+=1"
    set "MINOR=0"
    echo Bumping MAJOR version
) else if "%BUMP_TYPE%"=="2" (
    set /a "MINOR+=1"
    echo Bumping MINOR version
) else (
    echo Invalid choice. Defaulting to MINOR bump.
    set /a "MINOR+=1"
)

:: Create new version string
set "VERSION=%MAJOR%.%MINOR%"
set "ZIP_NAME=%FOLDER_NAME%_v%VERSION%.zip"
set "ZIP_PATH=%SOURCE_DIR%%ZIP_NAME%"

:: Update version in .toc file
echo Updating version in ImportCondenser.toc to %VERSION%...
powershell -Command "(Get-Content '%TOC_FILE%') -replace '## Version: .*', '## Version: %VERSION%' | Set-Content '%TOC_FILE%'"

echo Creating %ZIP_NAME%...
echo Source: %SOURCE_DIR%
echo Destination: %ZIP_PATH%

:: Use PowerShell to create the zip file
powershell -Command "Compress-Archive -Path '%SOURCE_DIR%ImportCondenser\*' -DestinationPath '%ZIP_PATH%' -Force"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Success! Created %ZIP_NAME%
    echo Location: %ZIP_PATH%
    
    :: Create git tag
    set "TAG_NAME=v%VERSION%"
    echo.
    echo Creating git tag: !TAG_NAME!
    git tag -a !TAG_NAME! -m "Release !TAG_NAME!"
    git push origin !TAG_NAME!
    
    if !ERRORLEVEL! EQU 0 (
        echo Git tag !TAG_NAME! created successfully
        echo.
        echo To push the tag to remote, run: git push origin !TAG_NAME!
    ) else (
        echo Warning: Failed to create git tag. Make sure you're in a git repository.
    )
) else (
    echo.
    echo Error: Failed to create zip file
)

pause
