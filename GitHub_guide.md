# Safer Git Workflow (Beginner-Friendly)

This guide explains a safe, simple workflow for updating your local files and pushing changes to GitHub only when *you* decide.  
It also shows how to use branches for even more protection and cleaner project history.

---

## 1. Update Your Local Files

Work normally on your computer. Edit files inside:

- `python/`
- `sql/`
- `R/`
- `PowerShell/`

Git does *not* push anything automatically — you are always in control.

---

## 2. Check What Has Changed

Use:

```bash
git status

this shows:

modified files
new files
deleted files
whether anything is staged
whether anything is committed


## 3. Review Exact Changes Before Committing
To see what changed:
```bash
git diff

To review a specific file:
```bash
git diff path/to/fileS

This ensures you know what you’re about to commit.

## 4. Stage Only the Changes You Want
Stage everything:
```bash
git add .
OR stage folders/files one by one:
```bash
git add python/
git add sql/
git add R/
git add PowerShell/

Check staging again:
Shellgit statusShow more lines
Staged files appear in green.

5. Commit Your Changes
Create a commit with a clear message:
Shellgit commit -m "Describe your changes here"Show more lines
You can make many commits locally — nothing is pushed yet.

6. Push ONLY When You Are Ready
Push your committed work to GitHub:
Shellgit pushShow more lines
For first time on a new branch:
Shellgit push -u origin mainShow more lines

7. Optional: Use Branches for Maximum Safety
Creating a separate branch protects your main branch from mistakes.
Create a new branch:
Shellgit checkout -b feature/my-changeShow more lines
Push it:
Shellgit push -u origin feature/my-changeShow more lines
Then open a Pull Request (PR) on GitHub to merge your branch into main.
Benefits of using branches:

You can review changes before merging
Easy to cancel or redo work
Keeps your main branch clean and stable
Works well with automated tests or checks
Safe for beginners
Standard practice in industry


Summary

Work locally
Review changes (git status, git diff)
Stage changes (git add)
Commit changes (git commit)
Push when ready (git push)
(Optional) Use feature branches + PRs for maximum safety

This workflow keeps everything clean, predictable, and easy to manage.
