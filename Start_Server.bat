@echo off
chcp 65001 >nul
title Gemini Web To API Server (Port 4981)
cls
echo ==============================================================
echo    Dang khoi dong Gemini Web to API tren cong 4981...
echo    Dia chi API: http://127.0.0.1:4981
echo    (De tat server, nhan to hop phim Ctrl + C hoac dong cua so)
echo ==============================================================
echo.

go run cmd/server/main.go
if %errorlevel% neq 0 (
    echo.
    echo [Loi] Server da dung. Vui long kiem tra lai Go va file .env!
    pause
)
