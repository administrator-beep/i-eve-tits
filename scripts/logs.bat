@echo off
REM View I-EVE-TITS Logs Windows Batch Wrapper

setlocal enabledelayedexpansion

cd /d "%~dp0"
set SCRIPT_DIR=%~dp0

REM Launch PowerShell with the logs script
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT_DIR%logs.ps1'"
