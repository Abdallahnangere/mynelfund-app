@echo off
title My NELFund Enterprise Admin Console
cd /d "%~dp0"

echo ========================================================
echo   Federal Republic of Nigeria - My NELFund Enterprise
echo   Official Admin Portal & Push Notification Center
echo ========================================================
echo.

if not exist node_modules (
    echo [Setup] Installing required node modules...
    call npm install
)

echo [Status] Launching Admin Server on http://localhost:4040 ...
start "" http://localhost:4040
node server.js
pause
