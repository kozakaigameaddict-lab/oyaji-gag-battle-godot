# AI Judge Test Report — Dajare Battle

## Purpose

Evaluate local AI models for use as the dajare judge in Dajare Battle.
The AI scores the player's dajare on four axes (total 100 points) and outputs a short Japanese comment.
No internet or API key is required — all inference runs locally via llama.cpp server.

---

## Test Environment

| Item | Detail |
|---|---|
| OS | Windows 11 |
| CPU | Intel Core i5-1334U (13th gen, 10 cores / 12 threads, 1.3 GHz base) |
| RAM | 16.0 GB |
| GPU | Intel Iris Xe Graphics (integrated, shared memory) |
| Inference server | llama.cpp b9012, Vulkan backend |
| Server command | `llama-server.exe --model <model> --port 8080` |
| Test tool | curl (Windows built-in) |

---

## Test Structure

### Scoring prompt (system message)

The AI receives a system message defining four scoring axes plus a category penalty rule:

| Field | Range | Description |
|---|---|---|
| `pun_score` | 0–30 | Phonetic similarity, naturalness of wordplay |
| `cold_score` | 0–30 | Lameness, awkwardness, dad joke feel |
| `scene_score` | 0–20 | Visual humor, surrealism of the scene |
| `addictive_score` | 0–20 | Originality, lingering impression |
| `penalty` | 0 or −50 | Applied if the dajare contains no words related to the theme |
| `comment` | string | Japanese only, casual tone, 30 characters maximum |

Output format: raw JSON only (no markdown).

**Total score is always calculated in game code** — AI arithmetic is not trusted.

### Test dajare

| Item | Content |
|---|---|
| Theme | 【動物】 |
| Dajare | 「地井武男がチーターKO」 |
| Expected penalty | 0 (チーター = cheetah = animal) |

---

## Models Tested

| # | Model file | Size | Developer | Base model |
|---|---|---|---|---|
| 1 | `gemma-3-1b-it-Q4_K_M.gguf` | ~0.7 GB | Google | Gemma 3 (original) |
| 2 | `Llama-3.2-3B-Instruct-Q4_K_M.gguf` | ~2.0 GB | Meta | Llama 3.2 (original) |
| 3 | `gemma-3-4b-it-Q4_K_M.gguf` | ~2.5 GB | Google | Gemma 3 (original) |
| 4 | `Llama-3-ELYZA-JP-8B-q4_k_m.gguf` | ~5.0 GB | ELYZA Inc. (Japan) | Meta Llama 3 |
| 5 | `qwen2.5-7b-instruct-q3_k_m.gguf` | ~3.5 GB | Alibaba | Qwen 2.5 (original) |
| 6 | `EZO-Common-9B-gemma-2-it.Q4_K_M.iMatrix.gguf` | ~5.5 GB | AXCXEPT Inc. (Japan) | Google Gemma 2 |

### Models eliminated before this test

| Model | Reason |
|---|---|
| `swallow-7b.Q4_K_M.gguf` | Base model (not instruct) — infinite loop |
| `Qwen2.5-7B.Q4_K_M.gguf` | Base model (not instruct) — infinite loop |
| `swallow-7b-instruct.Q4_K_M.gguf` | Chat template incompatible with llama.cpp — infinite loop |

---

## Test Results

### Raw scores

| Model | pun | cold | scene | addictive | penalty | Total* | Speed |
|---|---|---|---|---|---|---|---|
| Gemma 1B | 15 | 10 | 5 | 8 | 0 | **38** | ~1.5 sec |
| Llama 3.2 3B | 20 | 20 | 10 | 5 | 0 | **55** | ~4.4 sec |
| Gemma 3 4B | 20 | 15 | 10 | 15 | 0 | **60** | ~5.8 sec |
| ELYZA JP 8B | 20 | 10 | 10 | 5 | 0 | **45** | ~10.5 sec |
| Qwen2.5 7B | 10 | 10 | 5 | 5 | **50** | −30 | ~13 sec |
| EZO-Common 9B | 25 | 20 | 5 | 5 | 0 | **55** | ~17.7 sec |

*Total = pun + cold + scene + addictive − penalty (calculated in code, not from AI)

### Comments output

| Model | Comment | Language | Quality |
|---|---|---|---|
| Gemma 1B | (empty) | — | Failed |
| Llama 3.2 3B | 「おもちゃの犬の名前は犬?」 | Japanese | Wrong topic |
| Gemma 3 4B | 「ちょっと面白い！」 | Japanese | Simple but valid |
| ELYZA JP 8B | 「意外性が少しある」 | Japanese | Reasonable |
| Qwen2.5 7B | 「コウテイとKOの双関語使ってるけど」 | Japanese | Interesting but penalty wrong |
| EZO-Common 9B | 「定番のダジャレだけど、笑える」 | Japanese | Natural and relevant |

### JSON format

| Model | Output format | Issue |
|---|---|---|
| Gemma 1B | Clean JSON | None |
| Llama 3.2 3B | Clean JSON | None |
| Gemma 3 4B | Clean JSON | None |
| ELYZA JP 8B | Clean JSON | None |
| Qwen2.5 7B | Clean JSON | Penalty detection unreliable |
| EZO-Common 9B | Clean JSON | None |

---

## Overall Ranking

| Rank | Model | Strengths | Weaknesses |
|---|---|---|---|
| 1 | EZO-Common 9B | Best comment quality, reliable penalty | Slowest (18 sec) |
| 2 | Gemma 3 4B | Fast, clean JSON, decent comment | Scores slightly low |
| 3 | ELYZA JP 8B | Reliable, good Japanese | Slow (10 sec) |
| 4 | Llama 3.2 3B | Fast, clean JSON | Comment off-topic |
| 5 | Gemma 1B | Fastest | No comment output |
| 6 | Qwen2.5 7B | Good comment text | Penalty detection broken |

---

## Conclusion

**Best quality:** EZO-Common 9B — but 18 seconds is too slow for a game on integrated graphics.

**Best balance for this hardware:** Gemma 3 4B — 6 seconds, clean JSON, valid Japanese comment.

**Final model decision:** TBD — pending further evaluation or hardware upgrade.

---

## Notes

- All scores are from a single test run. Results may vary between runs (LLMs are non-deterministic).
- Penalty detection is unreliable in smaller models. Always validate in game code.
- Total score must always be calculated in game code — never trust the AI's arithmetic.
- Model files are not included in the git repository (too large). See `ai-judge-test-manual.md` for setup.
