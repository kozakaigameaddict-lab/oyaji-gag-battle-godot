# Development Roadmap — Dajare Battle

Each phase has a goal, tasks, and a "done" condition.
Work on phases in order. Do not move to the next phase until the done condition is met.

---

## Phase 0 — Environment Setup

**Goal:** Ready to write code.

### Tasks
- [x] Install Godot 4 (GDScript, standard version — not .NET)
- [x] Create a new Godot project
- [x] Set up folder structure (see below)
- [x] Install GUT (Godot Unit Test) plugin
- [x] Create GitHub repository (private first — go public in Phase 0.5)
- [x] Add `.gitignore` for Godot
- [x] First commit and push

### Folder Structure
```
res://
├── assets/
│   ├── audio/
│   ├── fonts/
│   └── images/
├── autoloads/
│   ├── audio_manager.gd
│   ├── scene_manager.gd
│   ├── save_manager.gd
│   └── service_locator.gd
├── domain/
│   ├── models/
│   └── services/
├── infrastructure/
│   └── judge/
├── scenes/
│   ├── title/
│   ├── story/
│   └── battle/
└── shared/
    └── components/
```

**Done condition:** Project opens in Godot, first commit is on GitHub (private).

---

## Phase 0.5 — GitHub Public Repository Lecture

**Goal:** Understand what "public" means and make the repository safe to publish.

### Why this matters
A public repository means anyone in the world can read every file and every commit history.
Secrets committed even once (and later deleted) can still be found in git history.

### Learn: What must never be in a public repo
- API keys (Claude, OpenAI, Gemini)
- Passwords, tokens, private URLs
- Personal information (address, email you don't want public)
- Paid asset files (check the license of each asset)
- `export_presets.cfg` if it contains signing passwords

### Learn: How to protect secrets in Godot
API keys must NEVER be stored in game files.
For a PC game, the correct approach is a **proxy server**:

```
Game → Your proxy server (holds the API key) → AI API
```

Players cannot extract a key they never receive.
A simple serverless function (Cloudflare Workers, AWS Lambda) is enough.
Cost for indie scale: nearly free.

> This will be implemented in Phase 3. For now, just understand the concept.

### Tasks
- [x] Read through [github-checklist.md](github-checklist.md) completely
- [x] Confirm `.gitignore` covers all secret files
- [x] Add a `config/` folder to `.gitignore`
- [x] Add `config.example.cfg` — template with placeholder values
- [x] Verify git history has no secrets
- [x] Make the repository public on GitHub
- [x] Branch rulesets configured (main + develop)
- [x] Merge strategy: squash only, auto-delete head branches
- [x] Secret scanning and push protection enabled
- [x] Private assets strategy decided (separate private repo)
- [x] `.claude/` added to `.gitignore`

**Done condition:** Repository is public. `config/` is git-ignored. No secrets in history. ✓

---

## Phase 1 — Architecture Foundation

**Goal:** Core systems in place before any game content.

### Tasks
- [x] Implement `ServiceLocator` autoload
- [x] Implement `SceneManager` autoload (change scenes with transition)
- [x] Implement `AudioManager` autoload (stub — play/stop BGM, SFX)
- [x] Implement `SaveManager` autoload (stub — save/load chapter unlock state, encrypted)
- [x] Write base class `JudgeServiceBase` in domain/services/
- [x] Write a `MockJudgeService` that returns a random score (for testing without API)
- [x] Register `MockJudgeService` in `ServiceLocator` via `GameInitializer`
- [x] Write first GUT test: confirm `ServiceLocator` registers and retrieves a service (4/4 passed)

### Why this first?
These systems are used by every scene. Building them first means you never have to rewrite later.

### Notes on save data encryption
Godot has built-in encrypted file access:
```gdscript
# 暗号化されたファイルを開く例
var file = FileAccess.open_encrypted_with_pass("user://save.dat", FileAccess.WRITE, "passphrase")
```
Use this for save data. The passphrase should be stored in the local config (git-ignored).

**Done condition:** `ServiceLocator.get_service("judge")` returns a mock score in a test scene. GUT test passes.

---

## Phase 2 — Battle Prototype (No Art)

**Goal:** The core battle loop works end-to-end with placeholder art.

### Tasks
- [x] Build `BattleScene` with all 6 sub-states as a state machine
  - State: TALK → MAIN → PLAYER_PRESENTATION → ENEMY_PRESENTATION → JUDGE → FRIEND_COMMENT → (loop)
- [x] MAIN state: topic label, text input, submit button, timer
- [x] PRESENTATION state: show player's and enemy's dajare as labels
- [x] JUDGE state: call `JudgeServiceBase` via `ServiceLocator`, show scores
- [x] FRIEND_COMMENT state: stub (content added in Phase 6)
- [x] 5-round logic (best of 3 wins) — updated from original spec
- [x] Win / lose detection — logs result; scene transition deferred to Phase 5

Use placeholder colored rectangles for characters. No real art yet.

**Done condition:** You can play up to 5 rounds against a mock CPU and the winner is correctly detected. ✓

---

## Phase 3 — AI Judge Integration

**Goal:** Replace mock judge with a real AI API, via a proxy server.

### Tasks
- [ ] Study Godot `HTTPRequest` node and `await` on signals
- [ ] Build a simple proxy server (Cloudflare Workers recommended — free tier is enough)
  - Receives: topic, player dajare, enemy dajare
  - Calls AI API with your key (stored on the server, never in the game)
  - Returns: scores as JSON
- [ ] Implement `ClaudeJudgeService` in infrastructure/judge/
- [ ] Implement `OpenAiJudgeService`
- [ ] Implement `GeminiJudgeService`
- [ ] Design the scoring prompt: topic + both dajare → scores + reason
- [ ] Test each API and compare quality and cost
- [ ] Choose one as default (swappable via `ServiceLocator`)
- [ ] Proxy server URL stored in git-ignored config file

**Done condition:** A real AI scores your dajare through the proxy server, with no API key in the game files.

---

## Phase 4 — Story / Visual Novel System

**Goal:** Story scenes work with dialogue, characters, and backgrounds.

### Tasks
- [ ] Design `DialogueData` resource (text, character name, character image, background)
- [ ] Load dialogue from resource files (`.tres` or `.json`)
- [ ] Build `StoryScene`: background, character sprite, dialogue window, name plate
- [ ] Config button + Config panel (volume, text speed, back to title)
- [ ] Text speed setting actually works
- [ ] Auto-advance or click-to-advance dialogue

**Done condition:** A full story sequence plays from a data file.

---

## Phase 5 — Title Scene & Chapter Select

**Goal:** The game has a proper start and chapter structure.

### Tasks
- [ ] Build `TitleScene`: background, logo, Start button
- [ ] Chapter Select panel: show 3 chapters, lock/unlock state
- [ ] Save/load unlock state with `SaveManager` (encrypted)
- [ ] Flow: Title → Chapter Select → StoryScene → BattleScene

**Done condition:** Full flow from Title to Battle works for Chapter 1.

---

## Phase 6 — Content Integration (3 Chapters)

**Goal:** All story and battle content is in the game.

### Tasks
- [ ] Enter all story dialogue data (coordinate with planner)
- [ ] Define battle topics for each chapter
- [ ] Define enemy characters and their dajare behavior (pre-written or AI-generated)
- [ ] Epilogue story scenes after each chapter win
- [ ] Chapter 2 and 3 unlock after winning the previous chapter

**Done condition:** All 3 chapters are playable from start to finish.

---

## Phase 7 — Art & Audio Integration

**Goal:** Replace all placeholder art with real assets.

### Tasks
- [ ] Receive character and background art from designer
- [ ] Replace placeholder rectangles with real sprites
- [ ] Add BGM to each scene
- [ ] Add SFX (button clicks, judge reveal, etc.)
- [ ] Tune volume defaults
- [ ] Verify all asset licenses allow Steam distribution

**Done condition:** The game looks and sounds like a real game.

---

## Phase 8 — Polish

**Goal:** The game feels good to play.

### Tasks
- [ ] Scene transition animations (fade in/out) — use built-in `Tween`
- [ ] Presentation animation (character zoom in)
- [ ] Judge scene animation (flag raise)
- [ ] UI polish (fonts, colors, layout)
- [ ] Text speed and volume settings save between sessions
- [ ] Surrender button in battle config works correctly
- [ ] All edge cases tested (timer runs out, empty input, API failure / timeout)

**Done condition:** Internal playtesting passes with no rough edges.

---

## Phase 9 — Steam Release Preparation

**Goal:** The game is ready to publish.

### Tasks
- [ ] Run through [github-checklist.md](github-checklist.md) one final time
- [ ] Export the game for Windows in Godot (export template setup)
- [ ] Create a Steamworks developer account ($100 fee)
- [ ] Integrate GodotSteam plugin
- [ ] Set up Steam store page (capsule art, description, screenshots, trailer)
- [ ] Submit for Steam review (~5 business days)
- [ ] Set a release date

**Done condition:** Steam page is live and the build passes Steam review.

---

## Phase 10 — Release & Post-Launch

### Tasks
- [ ] Release on Steam
- [ ] Monitor for bugs (Steam reviews, direct feedback)
- [ ] Plan VS mode / multiplayer (post-minimal model)

---

## Summary Table

| Phase | Goal | Key Skill to Learn |
|---|---|---|
| 0 | Environment setup | Godot install, project structure, GUT |
| 0.5 | GitHub public lecture | Secret management, proxy server concept |
| 1 | Architecture foundation | Autoloads, Service Locator, GDScript basics, encrypted save |
| 2 | Battle prototype | State machine, signals, UI nodes |
| 3 | AI judge + proxy server | HTTPRequest, async signals, serverless |
| 4 | Story system | Resources, data-driven design |
| 5 | Title & chapters | Scene switching, save/load |
| 6 | Content | Data entry, coordination with planner |
| 7 | Art & audio | Sprite nodes, AudioStreamPlayer |
| 8 | Polish | Tween, AnimationPlayer |
| 9 | Steam | Export, GodotSteam, store page |
| 10 | Release | — |
