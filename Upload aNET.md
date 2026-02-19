# Upload a .NET (Visual Studio) Project Folder to Azure DevOps Repos (Git) — Windows CMD

## 0) Prerequisites (one-time)

### Check Git

```cmd
git --version
```

### Set Git identity (recommended)

```cmd
git config --global user.name "Your Name"
```

```cmd
git config --global user.email "you@example.com"
```

### Enable Git Credential Manager (recommended for Azure DevOps login)

```cmd
git config --global credential.helper manager-core
```

---

## 1) Upload an existing local .NET folder to an EMPTY Azure DevOps repo

### Step 1 — Go to your project folder

```cmd
cd /d "C:\path\to\your\dotnet-project"
```

### Step 2 — Initialize Git

```cmd
git init
```

### Step 3 — Add the official Visual Studio .gitignore (best practice)

(Requires `curl` which exists on modern Windows)

```cmd
curl -L -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/VisualStudio.gitignore
```

### Step 4 — Stage all files

```cmd
git add .
```

### Step 5 — First commit

```cmd
git commit -m "Initial commit"
```

### Step 6 — Rename branch to main

```cmd
git branch -M main
```

### Step 7 — Add your Azure DevOps repo as origin

Replace ORG/PROJECT/REPO with yours:

```cmd
git remote add origin "https://dev.azure.com/ORG/PROJECT/_git/REPO"
```

### Step 8 — Push to Azure DevOps

```cmd
git push -u origin main
```

---

## 2) If you already ran this before and “origin already exists”

### Check current origin

```cmd
git remote -v
```

### Replace origin URL

```cmd
git remote set-url origin "https://dev.azure.com/ORG/PROJECT/_git/REPO"
```

### Push again

```cmd
git push -u origin main
```

---

## 3) Daily solo workflow (edit → commit → push)

### Check changes

```cmd
git status
```

### Add everything

```cmd
git add .
```

### Commit

```cmd
git commit -m "Your message"
```

### Push

```cmd
git push
```

---

# Azure DevOps Login / PAT Fix (when push fails)

## If you get: 401 / Authentication failed

### Option A — Clear stuck Windows credentials (common fix)

List stored credentials:

```cmd
cmdkey /list
```

Try deleting Azure-related entries:

```cmd
cmdkey /delete:dev.azure.com
```

```cmd
cmdkey /delete:visualstudio.com
```

Then push again:

```cmd
git push -u origin main
```

## Option B — Use a Personal Access Token (PAT) (most reliable)

Create PAT:
**Azure DevOps → User settings → Personal access tokens**
Permissions:

* **Code (Read & Write)**

Then push:

```cmd
git push -u origin main
```

When prompted:

* Username: your email (or anything)
* Password: your **PAT**

---

# Common .NET / Visual Studio Notes (what should NOT be committed)

If you used VisualStudio.gitignore, it already excludes typical junk like:

* `.vs/`
* `bin/`
* `obj/`
* `*.user`, `*.suo`
* build outputs and temporary files

---

# Common Errors (quick fixes)

## Error: src refspec main does not match any

You didn’t commit yet:

```cmd
git add .
```

```cmd
git commit -m "Initial commit"
```

```cmd
git branch -M main
```

```cmd
git push -u origin main
```

## Error: rejected (fetch first) / non-fast-forward

Pull then push:

```cmd
git pull --rebase
```

```cmd
git push
```
