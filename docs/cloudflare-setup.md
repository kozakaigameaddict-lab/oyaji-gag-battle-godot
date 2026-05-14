# Cloudflare Workers セットアップガイド

このゲームはだじゃれの判定にAI（Gemini）を使用します。
APIキーを守るため、ゲームはAIに直接アクセスせず、プロキシサーバー（Cloudflare Workers）を経由します。

```
ゲーム → Cloudflare Workers（プロキシ） → Gemini API
```

このガイドはプロキシサーバーのセットアップ手順です。

---

## 必要なアカウント

### 1. Cloudflareアカウント（無料）

1. https://cloudflare.com にアクセス
2. **Sign Up** をクリック
3. メールアドレスとパスワードを登録
4. メール認証を完了する

### 2. Google AI Studio アカウント（無料）

1. https://aistudio.google.com にアクセス
2. Googleアカウントでサインイン
3. **Get API Key → Create API key** をクリック
4. 表示されたAPIキーをコピーして安全な場所に保存する
   - ⚠️ このキーは一度しか表示されない
   - ⚠️ 絶対に他人に教えないこと

---

## 必要なソフトウェア

### Node.js

1. https://nodejs.org にアクセス
2. **LTS版** をダウンロードしてインストール

### Wrangler（Cloudflare CLI）

ターミナル（コマンドプロンプト）で実行:

```
npm install -g wrangler
```

### Cloudflareにログイン

```
wrangler login
```

ブラウザが開くので、Cloudflareアカウントで承認する。

---

## プロキシサーバーのセットアップ

### 1. プロジェクト作成

ターミナルで任意のフォルダに移動し、実行:

```
npm create cloudflare@latest dajare-battle-proxy
```

選択肢:
- **Worker only** を選択
- AGENTS.md → **No**
- git → **No**
- deploy → **No**

### 2. コードを配置

作成された `dajare-battle-proxy/src/index.js` を、開発者から受け取ったプロキシコードで置き換える。

### 3. APIキーをSecretに登録

```
cd dajare-battle-proxy
wrangler secret put GEMINI_API_KEY
```

プロンプトが表示されたら、Gemini APIキーを貼り付けてEnter。

### 4. デプロイ

```
npm run deploy
```

初回はサブドメインの登録を求められる:
- **Y** を押す
- 好きなサブドメイン名を入力（例: `yourname-dev`）
- このサブドメインは全Cloudflareユーザーで一意である必要がある

デプロイ完了後、以下のようなURLが表示される:
```
https://dajare-battle-proxy.yourname.workers.dev
```

このURLをコピーしておく。

---

## Godotプロジェクトの設定

1. `dajare-battle/config/` フォルダを作成する
2. その中に `config.cfg` ファイルを作成する
3. 以下の内容を入力し、URLを実際のものに置き換える:

```
[api]
proxy_url = "https://dajare-battle-proxy.yourname.workers.dev"
```

---

## 動作確認

ターミナルで以下を1行で実行（URLは自分のものに変更）:

```
curl -X POST https://dajare-battle-proxy.yourname.workers.dev -H "Content-Type: application/json" -d "{\"topic\":\"猫\",\"player_dajare\":\"猫がねこけた\",\"enemy_dajare\":\"猫がねころんだ\"}"
```

以下のようなJSONが返ってくれば成功:

```json
{"player_score": 80, "enemy_score": 70, "reason": "..."}
```

---

## APIキーの更新方法

Gemini APIキーを変更する場合:

```
wrangler secret put GEMINI_API_KEY
```

新しいキーを入力してEnter。再デプロイは不要。

---

## 注意事項

- `config/config.cfg` は `.gitignore` で除外されている — **絶対にコミットしないこと**
- Gemini APIキーは Cloudflare の Secret にのみ保存し、コードに書かないこと
- 無料枠: 1日100,000リクエストまで（インディーゲームには十分）
