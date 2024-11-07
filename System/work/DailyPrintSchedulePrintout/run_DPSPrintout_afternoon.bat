@echo off
cd /d %~dp0
Powershell.exe -ExecutionPolicy Bypass -File DPSPrintout_afternoon.ps1
if %ERRORLEVEL% neq 0 (
    echo An error occurred.
    pause
)
