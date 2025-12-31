@echo off
setlocal EnableExtensions EnableDelayedExpansion
title FULL ONE PACK - Clean + Fix Permissions + Update NuGet + Build + Push

REM ==========================================================
REM FULL ONE PACK CMD SCRIPT (Windows)
REM Author: Amir Mobasheraghdam
REM Run: CMD as Administrator
REM ==========================================================

REM ---------- 0) Go to repo root ----------
cd /d "PATH\TO\YOUR\REPO" || (
  echo [ERROR] Cannot access repo path. Edit the script and set correct PATH.
  pause
  exit /b 1
)

echo.
echo ==========================================================
echo   FULL ONE PACK - Starting...
echo   Repo: %CD%
echo ==========================================================
echo.

REM ---------- 1) Basic checks ----------
where git >nul 2>&1 || (
  echo [ERROR] git not found. Install Git for Windows and reopen CMD.
  pause
  exit /b 1
)

where dotnet >nul 2>&1 || (
  echo [ERROR] dotnet not found. Install .NET SDK and reopen CMD.
  pause
  exit /b 1
)

REM ---------- 2) Fix permissions (ownership + full control) ----------
echo [STEP] Taking ownership + granting Full Control...
takeown /F . /R /D Y >nul 2>&1
icacls . /grant %USERNAME%:(OI)(CI)F /T >nul 2>&1

REM ---------- 3) Kill Visual Studio / build processes that lock files ----------
echo [STEP] Killing locking processes (Visual Studio / MSBuild / ServiceHub)...
for %%P in (devenv.exe MSBuild.exe VBCSCompiler.exe) do (
  taskkill /F /IM %%P >nul 2>&1
)

REM Kill ServiceHub variants safely
for /f "tokens=2 delims=," %%A in ('tasklist /fo csv ^| findstr /i "ServiceHub"') do (
  set pname=%%~A
  if not "!pname!"=="" taskkill /F /IM "!pname!" >nul 2>&1
)

REM Also kill dotnet build servers if they lock files
taskkill /F /IM dotnet.exe >nul 2>&1

REM ---------- 4) Remove VS cache & build output ----------
echo [STEP] Cleaning .vs / bin / obj ...
if exist ".vs"  rmdir /s /q ".vs"  >nul 2>&1
if exist "bin"  rmdir /s /q "bin"  >nul 2>&1
if exist "obj"  rmdir /s /q "obj"  >nul 2>&1

REM Optional: common temp artifacts
if exist "*.user" del /f /q "*.user" >nul 2>&1
if exist "*.suo"  del /f /q "*.suo"  >nul 2>&1

REM ---------- 5) Ensure .gitignore contains required lines (no duplicates) ----------
echo [STEP] Updating .gitignore (no duplicate lines)...

if not exist ".gitignore" (
  type nul > ".gitignore"
)

call :EnsureIgnoreLine ".vs/"
call :EnsureIgnoreLine "bin/"
call :EnsureIgnoreLine "obj/"
call :EnsureIgnoreLine "*.user"
call :EnsureIgnoreLine "*.suo"
call :EnsureIgnoreLine "*.userosscache"
call :EnsureIgnoreLine "*.sln.docstates"
call :EnsureIgnoreLine "*.log"
call :EnsureIgnoreLine "Thumbs.db"
call :EnsureIgnoreLine ".DS_Store"

REM ---------- 6) Remove tracked cache folders from git index (if ever tracked) ----------
echo [STEP] Removing tracked cache folders from git index (if needed)...
git rm -r --cached .vs >nul 2>&1
git rm -r --cached bin >nul 2>&1
git rm -r --cached obj >nul 2>&1

REM ---------- 7) NuGet update (dotnet-outdated) ----------
echo [STEP] Installing/updating dotnet-outdated tool...
dotnet tool install --global dotnet-outdated-tool >nul 2>&1
dotnet tool update --global dotnet-outdated-tool  >nul 2>&1

echo [STEP] Listing outdated packages...
dotnet outdated

echo [STEP] Updating ALL outdated packages (may change csproj)...
dotnet outdated -u

REM ---------- 8) Restore + Build ----------
echo [STEP] Restoring...
dotnet restore
if errorlevel 1 (
  echo [ERROR] dotnet restore failed.
  pause
  exit /b 1
)

echo [STEP] Building Release...
dotnet build -c Release
if errorlevel 1 (
  echo [ERROR] dotnet build failed.
  pause
  exit /b 1
)

REM ---------- 9) Git status + commit + push ----------
echo.
echo [STEP] Git status:
git status

REM Check if this is actually a git repo
git rev-parse --is-inside-work-tree >nul 2>&1 || (
  echo [ERROR] This folder is not a git repository.
  echo         Run: git init  (or open correct repo folder)
  pause
  exit /b 1
)

REM Check if remote exists
git remote -v | findstr /i "origin" >nul 2>&1
if errorlevel 1 (
  echo [WARN] No 'origin' remote found. Set it first, then rerun:
  echo        git remote add origin YOUR_GITHUB_REPO_URL
  echo.
  echo [INFO] I will still create a local commit (no push).
)

REM Add and commit only if there are changes
git diff --quiet --ignore-submodules --cached
if not errorlevel 1 (
  REM staged exists - continue
) else (
  REM stage changes
  git add .
)

git diff --cached --quiet
if errorlevel 1 (
  echo [STEP] Committing...
  git commit -m "Full cleanup, NuGet update, stable build"
) else (
  echo [INFO] No changes to commit.
)

REM Push if origin exists
git remote -v | findstr /i "origin" >nul 2>&1
if not errorlevel 1 (
  echo [STEP] Pushing to origin...
  git push
) else (
  echo [INFO] Skipping push (origin remote not set).
)

echo.
echo ==========================================================
echo   DONE. If something failed, read the ERROR line above.
echo ==========================================================
pause
exit /b 0

REM ===================== FUNCTIONS ==========================
:EnsureIgnoreLine
set "LINE=%~1"
findstr /x /c:"%LINE%" ".gitignore" >nul 2>&1
if errorlevel 1 (
  echo %LINE%>> ".gitignore"
)
exit /b 0
