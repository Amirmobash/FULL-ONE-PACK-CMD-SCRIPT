# Azure DevOps Repo Upload (Windows CMD) — Full Guide (Solo)

## 0) Prerequisites

### Check Git is installed

```cmd
git --version
```

### (Recommended) Configure your name/email (once)

```cmd
git config --global user.name "Your Name"
```

```cmd
git config --global user.email "you@example.com"
```

---

## 1) Create/Find your Azure DevOps Repo URL

Your repo URL typically looks like:

```
https://dev.azure.com/ORG/PROJECT/_git/REPO
```

You’ll use it in commands below as:

```cmd
https://dev.azure.com/ORG/PROJECT/_git/REPO
```

---

# A) Upload an existing local folder to a NEW/EMPTY Azure DevOps repo (most common)

## 1) Go to your project folder

```cmd
cd /d "C:\path\to\your\project"
```

## 2) Initialize Git in that folder

```cmd
git init
```

## 3) Create a .gitignore (pick one option)

### Option 1 (Best): Download a common .NET/Visual Studio ignore (requires curl)

```cmd
curl -L -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/VisualStudio.gitignore
```

### Option 2 (No curl): Minimal ignore (works for many projects)

```cmd
echo .vs/>>.gitignore
```

```cmd
echo bin/>>.gitignore
```

```cmd
echo obj/>>.gitignore
```

```cmd
echo *.user>>.gitignore
```

```cmd
echo *.suo>>.gitignore
```

## 4) Stage everything

```cmd
git add .
```

## 5) Commit

```cmd
git commit -m "Initial commit"
```

## 6) Rename your branch to main

```cmd
git branch -M main
```

## 7) Add Azure DevOps as remote origin

```cmd
git remote add origin "https://dev.azure.com/ORG/PROJECT/_git/REPO"
```

## 8) Push to Azure DevOps

```cmd
git push -u origin main
```

---

# B) If you already have a local Git repo and just want to connect + push to Azure

## 1) Go to your project folder

```cmd
cd /d "C:\path\to\your\project"
```

## 2) Confirm it is a Git repo

```cmd
git rev-parse --is-inside-work-tree
```

## 3) Rename branch to main (optional but common)

```cmd
git branch -M main
```

## 4) Add (or fix) remote origin

### If you do NOT have origin yet

```cmd
git remote add origin "https://dev.azure.com/ORG/PROJECT/_git/REPO"
```

### If origin already exists and you need to replace it

```cmd
git remote set-url origin "https://dev.azure.com/ORG/PROJECT/_git/REPO"
```

## 5) Push

```cmd
git push -u origin main
```

---

# C) Alternative: Clone first, then copy your files into the cloned repo

## 1) Go to a workspace directory

```cmd
cd /d "C:\path\to\workspace"
```

## 2) Clone repo

```cmd
git clone "https://dev.azure.com/ORG/PROJECT/_git/REPO"
```

## 3) Enter the repo folder

```cmd
cd "REPO"
```

## 4) Copy your project files into this folder (using Explorer), then:

```cmd
git add .
```

```cmd
git commit -m "Add project files"
```

```cmd
git push
```

---

# Authentication / Login (fix common push issues)

Azure DevOps uses browser sign-in or a Personal Access Token (PAT).

## 1) Recommended: Enable Git Credential Manager (usually fixes login prompts)

```cmd
git config --global credential.helper manager-core
```

Now try pushing again:

```cmd
git push -u origin main
```

## 2) If you get 401 / Authentication failed: use a PAT

### Create a PAT in Azure DevOps

Path:
**Azure DevOps → User settings → Personal access tokens**
Permissions:

* **Code (Read & Write)**

### Remove stuck Windows credentials (optional but often helps)

List stored credentials:

```cmd
cmdkey /list
```

Delete entries related to Azure DevOps (try these if present):

```cmd
cmdkey /delete:dev.azure.com
```

```cmd
cmdkey /delete:visualstudio.com
```

### Push again and enter PAT when asked

```cmd
git push -u origin main
```

When prompted:

* Username: your email (or anything)
* Password: your **PAT**

---

# Daily “Push Everything” Commands (solo workflow)

## 1) Check status

```cmd
git status
```

## 2) Add all changes

```cmd
git add .
```

## 3) Commit with a message

```cmd
git commit -m "Update"
```

## 4) Push

```cmd
git push
```

---

# Common Errors & One-line Fixes

## Error: `src refspec main does not match any`

You haven’t committed yet:

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

## Error: `remote origin already exists`

Replace origin URL:

```cmd
git remote set-url origin "https://dev.azure.com/ORG/PROJECT/_git/REPO"
```

## Error: `rejected (fetch first)` or non-fast-forward

Pull and rebase then push:

```cmd
git pull --rebase
```

```cmd
git push
```

## Error: “fatal: not a git repository”

You’re not inside the project folder or not initialized:

```cmd
cd /d "C:\path\to\your\project"
```

```cmd
git init
```

---

# Optional (but very useful): Show current remote + branch

```cmd
git remote -v
```

```cmd
git branch
