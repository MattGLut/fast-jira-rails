#!/usr/bin/env pwsh
# FastJira Rails Server Startup Script
# Usage: .\start.ps1 [-Port 3001] [-Seed]

param(
    [int]$Port = 3001,
    [switch]$Seed
)

# Ruby environment setup (Smart App Control workaround)
$env:RI_FORCE_PATH_FOR_DLL = "1"
$env:PATH = "C:\Ruby33-x64\bin;C:\Ruby33-x64\lib\ruby\3.3.0\x64-mingw-ucrt;C:\Ruby33-x64\msys64\ucrt64\bin;C:\Ruby33-x64\msys64\usr\bin;" + $env:PATH

Write-Host ""
Write-Host "  FastJira Rails" -ForegroundColor Cyan
Write-Host "  =============" -ForegroundColor DarkCyan
Write-Host ""

# Ensure dependencies are installed
Write-Host "  Checking dependencies..." -ForegroundColor DarkGray
bundle check --quiet 2>$null
if (-not $?) {
    Write-Host "  Installing gems..." -ForegroundColor Yellow
    bundle install --quiet
}

# Run migrations
Write-Host "  Running migrations..." -ForegroundColor DarkGray
ruby bin/rails db:migrate 2>$null

# Optionally seed
if ($Seed) {
    Write-Host "  Seeding database..." -ForegroundColor Yellow
    ruby bin/rails db:seed
}

# Build Tailwind
Write-Host "  Building Tailwind CSS..." -ForegroundColor DarkGray
ruby bin/rails tailwindcss:build 2>$null

# Clean stale PID
Remove-Item "tmp\pids\server.pid" -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "  Starting server on http://localhost:$Port" -ForegroundColor Green
Write-Host "  Login: admin@fastjira.local / password123" -ForegroundColor DarkGray
Write-Host "  Press Ctrl+C to stop" -ForegroundColor DarkGray
Write-Host ""

ruby bin/rails server -p $Port -b 0.0.0.0
