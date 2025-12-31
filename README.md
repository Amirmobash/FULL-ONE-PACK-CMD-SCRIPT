@echo off
REM ============================================
REM ToolOrganizer - Full Cleanup, Update & Push
REM Author: Amir Mobasheraghdam
REM Run CMD as Administrator
REM ============================================

REM 0) Go to repository root
cd /d "PATH\TO\YOUR\REPO"

REM 1) Take ownership + full control
takeown /F . /R /D Y
icacls . /grant %USERNAME%:(OI)(CI)F /T

REM 2) Kill Visual Studio processes (unlock files)
taskkill /F /IM devenv.exe >nul 2>&1
taskkill /F /IM MSBuild.exe >nul 2>&1
taskkill /F /IM ServiceHub.Host.*.exe >nul 2>&1

REM 3) Remove Visual Studio cache & build outputs
rmdir /s /q .vs
rmdir /s /q bin
rmdir /s /q obj

REM 4) Ensure gitignore rules exist
echo .vs/>> .gitignore
echo bin/>> .gitignore
echo obj/>> .gitignore
echo *.user>> .gitignore
echo *.suo>> .gitignore
echo *.userosscache>> .gitignore
echo *.sln.docstates>> .gitignore

REM 5) Remove .vs from git index if ever tracked
git rm -r --cached .vs >nul 2>&1

REM 6) Install / Update NuGet outdated tool
dotnet tool install --global dotnet-outdated-tool
dotnet tool update --global dotnet-outdated-tool

REM 7) Update ALL NuGet packages
dotnet outdated
dotnet outdated -u

REM 8) Restore & Build
dotnet restore
dotnet build -c Release

REM 9) Commit & Push to GitHub
git status
git add .
git commit -m "Full cleanup, NuGet update, stable build"
git push

REM ============================================
REM DONE
REM ============================================
pause
