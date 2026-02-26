@echo off
REM Stop I-EVE-TITS Windows Batch Wrapper

setlocal enabledelayedexpansion

cd /d "%~dp0"
set SCRIPT_DIR=%~dp0

REM Launch PowerShell with the stop script
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT_DIR%stop.ps1'"
