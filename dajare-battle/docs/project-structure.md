# Project Structure Guide

## Root: `res://`

```
res://
├── addons/          ← Godot plugins (GUT etc.) — do not edit manually
├── assets/
│   ├── audio/       ← BGM / SFX (gitignored — managed in private repo)
│   ├── fonts/       ← font files
│   └── images/
│       └── placeholder/  ← placeholder art for development (committed)
├── autoloads/       ← Global singletons (Autoload scripts)
├── domain/          ← Game logic — no Godot Node classes here
│   ├── models/      ← Data classes (extend RefCounted)
│   └── services/    ← Service base classes (extend RefCounted)
├── infrastructure/  ← External systems (AI API, save files)
│   └── judge/       ← AI judge service implementations
├── scenes/          ← All game scenes (.tscn + presenter scripts)
│   ├── title/
│   ├── story/
│   └── battle/
└── shared/
    └── components/  ← Reusable utilities (DebugLogger, etc.)
```

---

## autoloads/

Global scripts registered as Autoload in Project Settings.
Accessible from anywhere by name.

| File | Class | Role |
|---|---|---|
| `service_locator.gd` | `ServiceLocator` | Registers and retrieves all services |
| `scene_manager.gd` | `SceneManager` | Scene transitions |
| `audio_manager.gd` | `AudioManager` | BGM / SFX playback |
| `save_manager.gd` | `SaveManager` | Save / Load game data (encrypted) |

---

## domain/models/

Plain data classes. Extend `RefCounted`. No Node, no Godot-specific APIs.

| File | Role |
|---|---|
| `battle_round.gd` | Data for one battle round (topic, scores, winner) |
| `chapter_data.gd` | Chapter metadata (title, unlock state) |
| `dialogue_data.gd` | One line of dialogue (text, speaker, background) |

---

## domain/services/

Base classes for services. Extend `RefCounted`. Concrete implementations are in `infrastructure/`.

| File | Role |
|---|---|
| `judge_service_base.gd` | Base class for AI judge — subclass for each API |

---

## infrastructure/judge/

Concrete AI judge implementations. Each extends `JudgeServiceBase`.

| File | Role |
|---|---|
| `mock_judge_service.gd` | Returns random score — used during development |
| `claude_judge_service.gd` | Calls Claude API via proxy server |
| `openai_judge_service.gd` | Calls OpenAI API via proxy server |
| `gemini_judge_service.gd` | Calls Gemini API via proxy server |

---

## scenes/

Each scene folder contains:
- `scene_name.tscn` — the scene file (nodes / UI layout)
- `scene_name_presenter.gd` — the Presenter script (logic)

| Folder | Scenes |
|---|---|
| `title/` | TitleScene |
| `story/` | StoryScene |
| `battle/` | BattleScene (contains all 6 sub-states) |

---

## shared/components/

Reusable utility classes. No game logic. Usable from any scene.

| File | Class | Role |
|---|---|---|
| `logger.gd` | `DebugLogger` | Debug log wrapper — suppressed in release builds |
