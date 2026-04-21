# Dajare Battle — Game Specification

## Overview

| Item | Detail |
|---|---|
| Title | Dajare Battle (working title) |
| Engine | Godot 4 |
| Platform | PC (Steam) |
| Genre | Turn-based battle / Visual novel hybrid |
| Language | Japanese |
| Judge System | AI-based scoring of dajare (Japanese puns) |

**Concept:** The player battles CPU opponents using Japanese dajare (puns / wordplay). Each dajare is judged by AI for creativity, relevance, and humor. Story chapters unlock after winning battles.

---

## Game Flow

```
Title Scene
  └─ Select Chapter
       └─ Story Scene (introduction)
            └─ Battle Scene
                 ├─ Talk Scene (pre-battle dialogue)
                 ├─ [Loop: up to 3 rounds]
                 │    ├─ 1. Talk Scene
                 │    ├─ 2. Main Scene       ← player inputs dajare
                 │    ├─ 3. Player Presentation Scene ← player's dajare revealed
                 │    ├─ 4. Enemy Presentation Scene  ← enemy's dajare revealed
                 │    ├─ 5. Judge Scene      ← AI scores both sides
                 │    └─ 6. Friend Comment Scene ← advice for higher score
                 │
                 ├─ [Player wins 2 rounds]
                 │    └─ Epilogue Story Scene
                 │         └─ Title Scene (next chapter unlocked)
                 │
                 └─ [Enemy wins 2 rounds]
                      └─ Game Over Screen
                           ├─ Retry → back to Talk Scene (same chapter)
                           └─ Return → Title Scene
```

---

## Scenes

### Title Scene
- Background image
- Title logo
- Buttons:
  - **Start Game** → opens Chapter Select panel

---

### Story Scene
- Background image
- Character sprites
- Config button → Config panel (Volume slider, Text speed, Back to title)
- Dialogue window with name plate

---

### Battle Scene

The battle scene has six sub-states per round:

#### 1. Talk Scene
- Same layout as Story Scene
- Background is the battle background

#### 2. Main Scene
- Background
- Character images (player + enemy)
- Topic label (the dajare theme — a single word)
- Timer display
- Player input text area
- Submit button

#### 3. Player Presentation Scene
- Zoomed player character image
- Speech bubble showing the player's dajare
- Background

#### 4. Enemy Presentation Scene
- Zoomed enemy character image
- Speech bubble showing the enemy's dajare
- Background

#### 5. Judge Scene
- Flag sprites:
  - White flag = Player
  - Red flag = Enemy
- Score/result presentation animation
- Result label

#### 6. Friend Comment Scene
- Friend character image
- Dialogue (advice for improving score)
- Background

#### Game Over Screen
- Result message
- **Retry** button → returns to Talk Scene (restarts the battle from round 1)
- **Return** button → returns to Title Scene

#### Config Button (always available during battle)
Opens config panel containing:
- Volume slider
- Text speed setting
- Back to title
- Surrender button

---

## Battle Rules

- 3 rounds per battle (maximum)
- Win condition: first to win **2 rounds** wins the battle
- Lose condition: enemy wins 2 rounds → player loses
- Topic per round: a **single word** — player must make a dajare related to that word

---

## Team

| Role | Person |
|---|---|
| Programming | User (self) |
| Planning / Story | Planner (story already written) |
| Art / Design | To be hired |
| Music / SFX | Free or paid web assets |

---

## Future Features (Post-Minimal Model)

- **VS Mode:** Battle against another human player
- **Multiplayer Mode:** Multiple player battle

---

## Open Questions / TBD

- AI judge: test Claude, OpenAI, and Gemini APIs — decide best after evaluation (Phase 3)
- Scoring criteria for dajare: TBD
- Game Over screen: **Retry** (back to Talk Scene) or **Return** (Title Scene) — decided.
- Number of chapters at launch: **3**
