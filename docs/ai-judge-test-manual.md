# AI Judge Test Manual

This manual explains how to test the local AI judge on your own PC.
No internet connection or API key is required after setup.

---

## Requirements

### Hardware
- Windows 10 or 11 (64-bit)
- RAM: 8 GB minimum (16 GB recommended for 8B+ models)
- GPU: Any GPU supporting Vulkan (NVIDIA / AMD / Intel Iris Xe)
- Storage: 1–6 GB free per model

### Software
- Command Prompt (built into Windows — do NOT use PowerShell for this)
- curl (built into Windows 10/11)

---

## Step 1 — Get the game folder

Clone or download the repository from GitHub.

```
git clone https://github.com/<repo-url>/oyaji-gag-battle-godot.git
```

The `dajare-battle/` folder is the Godot project root.

---

## Step 2 — Download llama.cpp server

Go to:
```
https://github.com/ggerganov/llama.cpp/releases/latest
```

Download the file that matches your GPU:

| GPU | File to download |
|---|---|
| NVIDIA | `llama-{version}-bin-win-cuda-cu12.2.0-x64.zip` |
| AMD or Intel | `llama-{version}-bin-win-vulkan-x64.zip` |
| No GPU (CPU only) | `llama-{version}-bin-win-noavx-x64.zip` |

Extract the zip. Copy **all files** from the extracted folder into `dajare-battle/llama-bin/` (create this folder).

The key file is `llama-server.exe`. The `.dll` files next to it are required — do not separate them.

---

## Step 3 — Download a model

Model files are not included in the repository (too large). Download at least one:

| Model | Size | Japanese | Download |
|---|---|---|---|
| Gemma 3 1B (fastest) | ~0.7 GB | Weak | https://huggingface.co/lmstudio-community/gemma-3-1b-it-GGUF |
| Gemma 3 4B (recommended) | ~2.5 GB | Moderate | https://huggingface.co/lmstudio-community/gemma-3-4b-it-GGUF |
| ELYZA JP 8B (best Japanese) | ~5.0 GB | Strong | https://huggingface.co/elyza/Llama-3-ELYZA-JP-8B-GGUF |
| EZO-Common 9B (best quality) | ~5.5 GB | Very strong | https://huggingface.co/AXCXEPT/EZO-Common-9B-gemma-2-it-GGUF |

On each page: click **Files and versions** → download the file ending in `Q4_K_M.gguf`.

Place the downloaded file in `dajare-battle/models/`:

```
dajare-battle/
├── llama-bin/
│   ├── llama-server.exe
│   └── *.dll
└── models/
    └── gemma-3-4b-it-Q4_K_M.gguf   ← here
```

---

## Step 4 — Start the server

Open **Command Prompt** and navigate to `dajare-battle/`:

```
cd C:\path\to\oyaji-gag-battle-godot\dajare-battle
```

Start the server (replace the filename with your downloaded model):

```
llama-bin\llama-server.exe --model models\gemma-3-4b-it-Q4_K_M.gguf --port 8080
```

Wait until you see:
```
main: server is listening on http://127.0.0.1:8080
```

Keep this window open.

---

## Step 5 — Create the test prompt file

Create a new file at `C:\Users\<YourName>\test_judge.json` with this content:

```json
{
  "model": "test",
  "messages": [
    {
      "role": "system",
      "content": "You are a dad joke judge. Score the given Japanese dad joke (だじゃれ) strictly based on these criteria:\n\n1. pun_score (0-30): Phonetic similarity, naturalness of wordplay\n2. cold_score (0-30): Lameness, awkwardness, dad joke feel\n3. scene_score (0-20): Visual humor, surrealism of the resulting scene\n4. addictive_score (0-20): Originality, lingering impression\n5. penalty: 50 if the joke contains NO words related to the theme. 0 if it does.\n\nOUTPUT RULES - strictly follow:\n- Start your response with { and end with }\n- Raw JSON only. Do NOT use ```json or any markdown.\n- No explanation, no text outside the JSON object.\n- Comment: Japanese only, casual tone, 30 characters maximum.\n\nFormat: {\"pun_score\": 0, \"cold_score\": 0, \"scene_score\": 0, \"addictive_score\": 0, \"penalty\": 0, \"comment\": \"\"}"
    },
    {
      "role": "user",
      "content": "テーマ:【動物】\nだじゃれ:「地井武男がチーターKO」\nJSON形式のみで採点してください。必ず { から始めてください。"
    }
  ]
}
```

To test a different dajare, change `content` in the `"role": "user"` section.

---

## Step 6 — Send a test request

Open a **second** Command Prompt window (leave the server running in the first one).

Run:

```
curl http://127.0.0.1:8080/v1/chat/completions -H "Content-Type: application/json" -d @C:\Users\<YourName>\test_judge.json
```

Replace `<YourName>` with your Windows username.

---

## Step 7 — Read the result

A successful response looks like:

```json
{
  "pun_score": 20,
  "cold_score": 15,
  "scene_score": 10,
  "addictive_score": 15,
  "penalty": 0,
  "comment": "ちょっと面白い！"
}
```

Calculate the total yourself:

```
total = pun_score + cold_score + scene_score + addictive_score - penalty
```

---

## Step 8 — Stop the server

Go to the server window and press `Ctrl + C`.

---

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| `llama-server.exe` not found | Wrong folder | Check you are in `dajare-battle/` |
| DLL missing error | Incomplete extraction | Copy ALL files from the zip, not just `.exe` |
| Server starts but no response | Model still loading | Wait 10–30 seconds after "listening" message |
| Response is not JSON | Model too small | Try a larger model (4B or above) |
| Penalty is wrong | Model limitation | Known issue — total is calculated in game code |
| Response takes 30+ seconds | No dedicated GPU | Expected on CPU-only or integrated graphics |

---

## Saving results

To save all results to a file automatically, use `>>`:

```
curl http://127.0.0.1:8080/v1/chat/completions -H "Content-Type: application/json" -d @C:\Users\<YourName>\test_judge.json >> result.txt
```

Each run appends to `result.txt`. Share this file for comparison.
