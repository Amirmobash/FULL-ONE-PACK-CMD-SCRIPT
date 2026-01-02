@echo off
setlocal EnableExtensions EnableDelayedExpansion
title FULL ONE PACK - Clean + Fix Locks + Restore + Build + Sync + Push

REM ==========================================================
REM FULL ONE PACK CMD SCRIPT (Windows)
REM Author: Amir Mobasheraghdam
REM Run: CMD as Administrator (recommended)
REM NOTE:
REM  - This script does NOT do "takeown/icacls" by default anymore.
REM    Permission issues are usually from locked files, not ACLs.
REM  - It cleans Visual Studio caches safely and fixes Git push issues.
REM ==========================================================

REM ---------- 0) Go to repo root ----------
REM !!! EDIT THIS PATH !!!
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

REM Check if this is actually a git repo
git rev-parse --is-inside-work-tree >nul 2>&1 || (
  echo [ERROR] This folder is not a git repository.
  echo         Open the correct repo folder or run: git init
  pause
  exit /b 1
)

REM ---------- 2) Kill Visual Studio / build processes that lock files ----------
echo [STEP] Killing locking processes (Visual Studio / MSBuild / ServiceHub / dotnet)...
for %%P in (devenv.exe MSBuild.exe VBCSCompiler.exe) do (
  taskkill /F /IM %%P >nul 2>&1
)

REM Kill ServiceHub variants safely
for /f "tokens=2 delims=," %%A in ('tasklist /fo csv ^| findstr /i "ServiceHub"') do (
  set "pname=%%~A"
  if not "!pname!"=="" taskkill /F /IM "!pname!" >nul 2>&1
)

REM dotnet build servers can lock files too
taskkill /F /IM dotnet.exe >nul 2>&1

REM ---------- 3) Remove VS cache & build output (IMPORTANT: remove nested .vs too) ----------
echo [STEP] Cleaning .vs / bin / obj (recursive)...

REM Remove all .vs folders anywhere
for /d /r %%D in (.vs) do (
  if exist "%%D" (
    echo   - Deleting: %%D
    rmdir /s /q "%%D" >nul 2>&1
  )
)

REM Remove all bin and obj folders anywhere
for /d /r %%D in (bin obj) do (
  if exist "%%D" (
    echo   - Deleting: %%D
    rmdir /s /q "%%D" >nul 2>&1
  )
)

REM Remove common user files (recursive)
del /s /f /q *.user  >nul 2>&1
del /s /f /q *.suo   >nul 2>&1
del /s /f /q *.userosscache >nul 2>&1
del /s /f /q *.sln.docstates >nul 2>&1

REM ---------- 4) Ensure .gitignore contains required lines (no duplicates) ----------
echo [STEP] Updating .gitignore (no duplicate lines)...

if not exist ".gitignore" (
  type nul > ".gitignore"
)

call :EnsureIgnoreLine ".vs/"
call :EnsureIgnoreLine "**/.vs/"
call :EnsureIgnoreLine "bin/"
call :EnsureIgnoreLine "obj/"
call :EnsureIgnoreLine "**/bin/"
call :EnsureIgnoreLine "**/obj/"
call :EnsureIgnoreLine "*.user"
call :EnsureIgnoreLine "*.suo"
call :EnsureIgnoreLine "*.userosscache"
call :EnsureIgnoreLine "*.sln.docstates"
call :EnsureIgnoreLine "*.log"
call :EnsureIgnoreLine "Thumbs.db"
call :EnsureIgnoreLine "Desktop.ini"
call :EnsureIgnoreLine ".DS_Store"

REM ---------- 5) Remove tracked cache folders from git index (if they were tracked) ----------
echo [STEP] Removing tracked cache folders from git index (if needed)...

REM Important: remove recursively by pattern; ignore errors
git rm -r --cached .vs >nul 2>&1
git rm -r --cached **/.vs >nul 2>&1
git rm -r --cached bin >nul 2>&1
git rm -r --cached obj >nul 2>&1
git rm -r --cached **/bin >nul 2>&1
git rm -r --cached **/obj >nul 2>&1

REM ---------- 6) Restore + Build (Release) ----------
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

REM ---------- 7) Git status ----------
echo.
echo [STEP] Git status:
git status

REM ---------- 8) Commit if needed ----------
REM Stage changes
echo [STEP] Staging changes...
git add -A
if errorlevel 1 (
  echo [ERROR] git add failed. Usually still-locked files.
  echo        Close Visual Studio and rerun this script.
  pause
  exit /b 1
)

REM Commit only if there are staged changes
git diff --cached --quiet
if errorlevel 1 (
  echo [STEP] Committing...
  git commit -m "Cleanup VS cache, rebuild Release"
) else (
  echo [INFO] No changes to commit.
)

REM ---------- 9) Push (handle non-fast-forward) ----------
REM Check if remote exists
git remote -v | findstr /i "origin" >nul 2>&1
if errorlevel 1 (
  echo [WARN] No 'origin' remote found. Set it first:
  echo        git remote add origin YOUR_GITHUB_REPO_URL
  echo [INFO] Skipping push.
  goto :DONE
)

echo [STEP] Pulling latest from origin (rebase) to avoid non-fast-forward...
git pull --rebase
if errorlevel 1 (
  echo [ERROR] git pull --rebase failed.
  echo        You may have conflicts. Resolve them, then run:
  echo        git add -A
  echo        git rebase --continue
  echo        git push
  pause
  exit /b 1
)

echo [STEP] Pushing to origin...
git push
if errorlevel 1 (
  echo [ERROR] git push failed.
  echo        If it still says non-fast-forward, run:
  echo        git pull --rebase
  echo        git push
  pause
  exit /b 1
)

:DONE
echo.
echo ==========================================================
echo   DONE.
echo   - .vs/bin/obj cleaned
echo   - .gitignore updated
echo   - Restore + Release build OK
echo   - Git sync + push done (if origin existed)
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
