# FULL ONE PACK CMD SCRIPT
### Windows – Full Control, Clean, Update NuGet, Build & Push

**Author:** Amir Mobasheraghdam

A single, all-in-one **Windows CMD script** designed to fully prepare a Visual Studio / .NET project
for a clean and error-free GitHub push.

This script handles **permissions, locked files, cleanup, NuGet updates, build, and Git push**
in one run.

---

## ⚠️ Important
- **Run CMD as Administrator**
- Edit the repository path before running:
```

cd /d "PATH\TO\YOUR\REPO"

````

---

## What This Script Does (Step by Step)

---

### 1️⃣ Change to Repository Root
Moves CMD to the root folder of your Git repository.

```bat
cd /d "PATH\TO\YOUR\REPO"
````

---

### 2️⃣ Take Ownership & Grant Full Control

Fixes all permission issues that cause *Permission denied* errors.

```bat
takeown /F . /R /D Y
icacls . /grant %USERNAME%:(OI)(CI)F /T
```

---

### 3️⃣ Kill Locking Processes

Stops Visual Studio and related background services that lock files.

```bat
taskkill /F /IM devenv.exe
taskkill /F /IM MSBuild.exe
taskkill /F /IM ServiceHub.Host.*.exe
```

---

### 4️⃣ Remove Visual Studio Cache & Build Outputs

Deletes folders that **must never be committed** to GitHub.

```bat
rmdir /s /q .vs
rmdir /s /q bin
rmdir /s /q obj
```

---

### 5️⃣ Update `.gitignore`

Ensures Visual Studio cache and build files are ignored permanently.

```bat
echo .vs/>> .gitignore
echo bin/>> .gitignore
echo obj/>> .gitignore
echo *.user>> .gitignore
echo *.suo>> .gitignore
echo *.userosscache>> .gitignore
echo *.sln.docstates>> .gitignore
```

---

### 6️⃣ Remove Cached Files from Git Index

If `.vs`, `bin`, or `obj` were ever committed before, they are removed safely.

```bat
git rm -r --cached .vs
```

---

### 7️⃣ Install / Update NuGet Outdated Tool

Installs the official tool used to detect and update outdated NuGet packages.

```bat
dotnet tool install --global dotnet-outdated-tool
dotnet tool update --global dotnet-outdated-tool
```

---

### 8️⃣ Update ALL NuGet Packages

Lists outdated packages and updates them automatically.

```bat
dotnet outdated
dotnet outdated -u
```

---

### 9️⃣ Restore & Build Project

Ensures the project builds successfully after updates.

```bat
dotnet restore
dotnet build -c Release
```

---

### 🔟 Commit & Push to GitHub

Stages changes, commits, and pushes to the remote repository.

```bat
git status
git add .
git commit -m "Update NuGet packages and clean VS cache"
git push
```

---

## ✅ When to Use This Script

* Before pushing a Visual Studio project to GitHub
* When Git shows **Permission denied**
* When `.vs`, `bin`, or `obj` cause Git errors
* After updating NuGet packages
* To fully clean and stabilize a repository

---

## ❌ What This Script Intentionally Removes

These should **never** be in a Git repository:

* `.vs/`
* `bin/`
* `obj/`

---

## Requirements

* Windows
* Git for Windows
* .NET SDK (`dotnet` command available)
* CMD running as **Administrator**

---

## License

Use freely. No warranty. Intended for professional and industrial workflows.Amir Mobasheraghdam
