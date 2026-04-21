# Code Convention — Dajare Battle

## Language & Engine

- **Engine:** Godot 4.x
- **Language:** GDScript
- **Target:** PC / Steam

---

## Architecture

### Clean Architecture — Layer Overview

```
┌─────────────────────────────┐
│  Presentation Layer         │  Scenes, UI Nodes, Animations
│  (View + Presenter)         │
├─────────────────────────────┤
│  Domain Layer               │  Game rules, Use cases, Entities
│  (Model + Logic)            │
├─────────────────────────────┤
│  Infrastructure Layer       │  API calls (AI judge), Save/Load, File I/O
└─────────────────────────────┘
```

Dependencies only flow **downward**: Presentation → Domain → Infrastructure.

> **GDScript note:** The Domain layer must not use `Node`-based classes.
> Use `RefCounted` (or plain `Object`) as the base class for all Domain models and services.
> `Node` is for scene trees only.

---

### MVP Pattern

Each scene follows the Model-View-Presenter pattern:

| Role | Godot equivalent | Responsibility |
|---|---|---|
| **Model** | Class extending `RefCounted` | Data only. No Nodes. |
| **View** | Scene `.tscn` + Node script (partial) | Display only. No game logic. |
| **Presenter** | Script attached to root node of scene | Connects Model and View. Handles input and state. |

**Rule:** Views must not call Model methods directly. All logic goes through the Presenter.

---

### Singleton — Service Locator Pattern

In Godot, `Autoload` (built-in global singleton) is a standard feature and **not** anti-pattern.
However, overusing Autoloads creates tight coupling and hurts testability.

**Rule:**
- Use `Autoload` only for truly global services (see table below).
- For other dependencies, use **Service Locator**.

#### Allowed Autoloads (Global Services)

| Autoload Name | Responsibility |
|---|---|
| `AudioManager` | BGM / SFX playback |
| `SceneManager` | Scene transitions |
| `SaveManager` | Save / Load game data |
| `ServiceLocator` | Registers and provides all other services |

#### Service Locator Usage

```gdscript
# サービスの登録例 (ServiceLocator への登録)
ServiceLocator.register("judge_service", ClaudeJudgeService.new())

# サービスの取得例
var judge = ServiceLocator.get_service("judge_service")
```

GDScript has no interfaces. Define services as **base classes extending `RefCounted`** with virtual methods.
Concrete implementations live in the Infrastructure layer.

```gdscript
# domain/services/judge_service_base.gd
## AI判定サービスの基底クラス。具体的な実装はインフラ層に置く。
class_name JudgeServiceBase
extends RefCounted

## だじゃれを判定してスコアを返す（サブクラスでオーバーライドする）
func judge(topic: String, player_dajare: String, enemy_dajare: String) -> Dictionary:
    return {}
```

---

## Naming Conventions

GDScript follows the [official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).

| Target | Convention | Example |
|---|---|---|
| Class (`class_name`) | PascalCase | `BattlePresenter` |
| Function / method | snake_case | `submit_dajare()` |
| Variable | snake_case | `current_round` |
| Private variable | `_snake_case` | `_current_round` |
| Constant | UPPER_SNAKE_CASE | `MAX_ROUNDS` |
| Signal | snake_case | `dajare_submitted` |
| Enum name | PascalCase | `BattleState` |
| Enum value | UPPER_SNAKE_CASE | `BattleState.JUDGE` |
| Scene file | `snake_case.tscn` | `battle_scene.tscn` |
| Script file | `snake_case.gd` | `battle_presenter.gd` |
| Node name in scene | PascalCase | `SubmitButton` |

---

## Comments

- **All comments must be written in Japanese.**
- Every class, method, and non-obvious logic block must have a Japanese comment.
- Goal: the planner must be able to read and understand the code flow.
- Use `##` for doc comments (shown in the Godot editor tooltip). Use `#` for inline comments.

```gdscript
## バトルの1ラウンドを管理するプレゼンター。
## プレイヤーのだじゃれ入力〜判定〜結果表示までのフローを制御する。
class_name BattlePresenter
extends Node

# 現在のラウンド数 (1〜3)
var _current_round: int = 0
```

---

## Memory Management (GC Measures)

GDScript is garbage collected. Follow these rules to avoid memory leaks:

1. **Always call `queue_free()`** on nodes you instantiate dynamically when they are no longer needed.
   - Use `queue_free()` (not `free()`) for nodes — it waits until the end of the frame, which is safer.
2. **Disconnect signals** in `_exit_tree()` if you connected them manually with `connect()`.
3. **Avoid creating objects inside `_process()`** — allocate in `_ready()` or reuse pooled objects.
4. **HTTPRequest node** (used for AI API calls) — add it as a child node and reuse it; do not create a new one every call.

```gdscript
func _exit_tree() -> void:
    # ノード破棄時にシグナルを切断する
    _submit_button.pressed.disconnect(_on_submit_pressed)
```

---

## Refactoring Rules

- **Refactoring is mandatory.** Before adding a new feature, review related existing code and clean it up first.
- No "temporary" code committed to `main` or `develop`.
- A function that does more than one thing must be split.
- Magic numbers must be replaced with named constants or `@export` variables.

---

## Extensibility Guidelines

- AI judge is accessed through `JudgeServiceBase`. Swapping Claude / OpenAI / Gemini requires only a new subclass — no changes to game logic.
- Each battle sub-state (Talk, Main, PlayerPresentation, EnemyPresentation, Judge, FriendComment) is a separate state class. Adding a new state does not break existing states.
- Chapters are data-driven (loaded from `.tres` Resource files), not hard-coded.

---

## Godot-Specific Recommendations

| Topic | Recommendation |
|---|---|
| Scene composition | Prefer composition over inheritance. One scene = one responsibility. |
| Signals | Use Godot signals for communication between parent and child nodes. Do NOT use `get_node()` to reach sibling or parent nodes from deep inside a tree. |
| Exported variables | Use `@export` for values the designer needs to adjust (timers, speeds, colors). |
| Resources | Store game data (chapter data, character data) as `.tres` Resource files, not hard-coded. |
| State machine | Implement battle flow as a state machine (not a chain of `if` statements). |
| Async HTTP | Use `HTTPRequest` node with `await request_completed` for AI API calls. Never block the main thread. |
| Domain base class | Extend `RefCounted` (not `Node`) for all Domain layer classes. |

---

## Git & GitHub

See [github-checklist.md](github-checklist.md) for the public repository checklist.

Branch strategy:
- `main` — stable, releasable
- `develop` — integration branch
- `feature/xxx` — individual features
- `fix/xxx` — bug fixes

Commit message format:
```
[type] short description (in English or Japanese)

Types: feat, fix, refactor, docs, chore, test
Example: [feat] バトルシーンのタイマー実装
```
