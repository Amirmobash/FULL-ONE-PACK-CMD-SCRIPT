# Fix: `Permission denied` on `.vs/*.vsidx` when running Git (Visual Studio)

This error usually happens because **Visual Studio is still running** (or its background services), and Windows keeps files inside the `.vs` folder **locked**. Git then fails to read them during `git add`.

## ✅ Step 1 — Close Visual Studio completely

Close all Visual Studio windows.

## ✅ Step 2 — Kill Visual Studio background processes (Windows CMD as Admin)

Open **Command Prompt as Administrator** and run:

```bat
taskkill /F /IM devenv.exe
taskkill /F /IM ServiceHub.Host*.exe
taskkill /F /IM MSBuild.exe
taskkill /F /IM VBCSCompiler.exe
taskkill /F /IM dotnet.exe
```

## ✅ Step 3 — Delete the `.vs` folder (locked cache)

Run in the same CMD:

```bat
rmdir /S /Q ToolOrganizer\.vs
```

If your `.vs` folder is at the solution root, run this too:

```bat
rmdir /S /Q .vs
```

## ✅ Step 4 — Remove `.vs` from Git (if it was tracked before)

Open **Git Bash** and run:

```bash
git rm -r --cached .vs ToolOrganizer/.vs 2>/dev/null
git add .
git commit -m "Fix: remove Visual Studio cache (.vs) from repo"
```

## ✅ Step 5 — Sync if push is rejected (non-fast-forward)

If push says your branch is behind remote, do:

```bash
git pull --rebase
git push
```

---

# Recommended `.gitignore` for Visual Studio + .NET (must-have)

Make sure your `.gitignore` includes:

```gitignore
# Visual Studio cache
.vs/
**/.vs/

# Build outputs
bin/
obj/
**/bin/
**/obj/

# User-specific VS files
*.user
*.suo
*.userosscache
*.sln.docstates

# Rider/Resharper
.idea/
_ReSharper*/
*.DotSettings.user

# OS junk
Thumbs.db
Desktop.ini
.DS_Store
```

---

## Why this happens Amir Mobasheraghdam UNI BONN

* `.vs/` is **Visual Studio internal cache**
* `.vsidx` files are often **locked**
* They should **never** be committed

---
