# .gitignore Guide

## What is .gitignore?

`.gitignore` tells Git which files to **never track**.
Files listed here will not appear in SourceTree as "uncommitted changes" and will never be committed.

> Important: if a file was already committed before being added to `.gitignore`, Git will still track it.
> You must manually remove it from Git history. This is why `.gitignore` must be set up **before** the first commit.

---

## Current .gitignore — Line by Line

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

| Entry | Why ignore |
|---|---|
| `.godot/` | Godot's auto-generated cache folder. Same concept as Unity's `Library/` folder. Regenerated automatically — never commit. |
| `*.translation` | Compiled translation binary files. Generated from source text files — not needed in the repo. |
| `export_presets.cfg` | Godot export settings. Can contain signing passwords and personal paths. |
| `config/` | Our custom folder for API keys and proxy server URL. Must never be public. |
| `.env` | Environment variable file. Often used to store secrets locally. |
| `*.secret` | Any file ending in `.secret` — a safety net for local secret files. |
| `.DS_Store` | Mac OS system file. Harmless but noisy. |
| `Thumbs.db` | Windows thumbnail cache. Harmless but noisy. |

---

## What is NOT ignored (and why)

| File/Folder | Why commit |
|---|---|
| `*.tscn` | Scene files — core game content. |
| `*.gd` | GDScript source files — core game logic. |
| `*.tres` | Resource files — game data (dialogue, chapter data, etc.). |
| `*.import` | Import settings for assets. If ignored, collaborators must re-import every asset manually. |
| `*.uid` | Godot 4.3+ UID files. Help Godot resolve asset paths correctly across machines. |
| `project.godot` | Project settings file. Required — without this the project cannot open. |
| `addons/` | Plugins (e.g., GUT). Commit so all collaborators have the same plugins. |
| `assets/` | Images, audio, fonts. Commit all assets. |

---

## .gitignore Syntax Rules

| Syntax | Meaning | Example |
|---|---|---|
| `folder/` | Ignore entire folder and its contents | `.godot/` |
| `*.ext` | Ignore all files with this extension | `*.secret` |
| `filename` | Ignore this exact file anywhere in the repo | `.env` |
| `folder/file` | Ignore a specific file in a specific folder | `config/api_keys.cfg` |
| `#` | Comment line — ignored by Git | `# this is a comment` |
| `!filename` | **Exception** — do NOT ignore this, even if a rule above matched | `!config/config.example.cfg` |

---

## When to Add Something New

Add a new entry to `.gitignore` when:
- You create a file that contains a secret (API key, password, token).
- You create a file that is auto-generated and can be rebuilt (cache, compiled output).
- You add a tool that generates OS-specific files (e.g., IDE settings you don't want to share).

**How to add in SourceTree:**
1. Open `.gitignore` in any text editor.
2. Add the new entry on a new line.
3. Save the file.
4. In SourceTree, the previously visible file will disappear from the "Unstaged" list.

---

## Special Case: config/ folder

We use `config/` for local secrets (proxy server URL, etc.).
The folder itself is ignored, but we commit a **template file** so collaborators know what to create.

```
config/                    ← ignored (contains real secrets)
config.example.cfg         ← committed (template with placeholder values)
```

`config.example.cfg` example content:
```
[api]
proxy_url = "https://your-proxy-server-url-here"
```

When a new developer joins, they copy `config.example.cfg` → `config/config.cfg` and fill in the real values.
