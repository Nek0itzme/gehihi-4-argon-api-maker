@echo off
chcp 65001 >nul
title Gemini Web to API - Claude Code Setup
cls
echo ==============================================================
echo    Dang khoi dong cong cu cai dat Gemini Web -> Claude Code...
echo ==============================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
if %errorlevel% neq 0 (
    echo.
    echo [Loi] Da co loi xay ra hoac tien trinh da bi dung.
    pause
)
