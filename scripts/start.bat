@echo off
REM Start I-EVE-TITS Windows Batch Wrapper

setlocal enabledelayedexpansion

cd /d "%~dp0"
set SCRIPT_DIR=%~dp0
set REPO_DIR=%SCRIPT_DIR:~0,-1%\repo

if not exist "%REPO_DIR%" (
    echo Error: Repository directory not found
    echo Please reinstall I-EVE-TITS
    pause
    exit /b 1
)

REM Launch PowerShell with the start script
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT_DIR%start.ps1'"
