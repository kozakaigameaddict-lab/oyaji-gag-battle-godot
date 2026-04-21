# GitHub Public Repository Checklist

Before making the repository public, verify every item below.
Work through this list top to bottom — security items are first because git history is permanent.

---

## 1. Security (most critical)

- [ ] No API keys, tokens, or secrets anywhere in the code
- [ ] No hardcoded passwords, connection strings, or private URLs
- [ ] `config/` folder is listed in `.gitignore` (this is where local API config lives)
- [ ] `export_presets.cfg` checked — it can contain signing passwords; add it to `.gitignore`
- [ ] `.env` file (if used) is listed in `.gitignore`
- [ ] **Check git history:** run `git log --all --oneline` and scan for any commits that may have included secrets. If found, rewrite history with `git filter-repo` before going public.

---

## 2. Repository Setup

- [ ] `.gitignore` is set up correctly for Godot 4 + GDScript (see template below)
- [ ] `README.md` exists and describes the project
- [ ] `LICENSE` file added (choose: MIT, GPL, or proprietary)
- [ ] Repository description and topics set on GitHub

---

## 3. Code Quality

- [ ] No debug `print()` statements left in the code unintentionally
- [ ] No TODO/FIXME comments that reference unfinished or broken features
- [ ] No placeholder or test assets committed to the repository

---

## 4. Assets

- [ ] All asset licenses verified — confirm free/paid assets **allow inclusion in a public repository**
- [ ] No personal photos, private data, or uncleared copyrighted material

---

## Godot 4 `.gitignore` (GDScript)

```gitignore
# Godot キャッシュ・生成ファイル
.godot/
*.translation
export_presets.cfg

# ローカル設定・シークレット
config/
.env
*.secret

# OS
.DS_Store
Thumbs.db
```
