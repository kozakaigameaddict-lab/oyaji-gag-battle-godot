extends JudgeServiceBase
class_name GeminiJudgeService

## GeminiAPI経由のだじゃれ判定サービス。
## プロキシサーバー（Cloudflare Workers）を経由してGemini APIを呼び出す。
## APIキーはプロキシサーバー側で管理し、ゲーム内には保持しない。


# --- プライベート変数 ---

# HTTPリクエストを送受信するノード（外部から注入する）
var _http_request: HTTPRequest
# プロキシサーバーのURL（config/config.cfgから読み込む）
var _proxy_url: String = ""


# --- パブリックメソッド ---

## 依存するHTTPRequestノードを受け取り、設定ファイルからプロキシURLを読み込む。
func _init(http_request: HTTPRequest) -> void:
	_http_request = http_request
	_load_config()


## だじゃれを判定してスコアを返す。
## プロキシにPOSTリクエストを送り、Geminiの判定結果を受け取る。
func judge(_topic: String, _player_dajare: String, _enemy_dajare: String) -> Dictionary:
	if _proxy_url.is_empty():
		DebugLogger.error("proxy_urlが設定されていません", DebugCategories.Category.BATTLE_JUDGE)
		return {}

	# プロキシに送るJSONボディを組み立てる
	var body: String = JSON.stringify({
		"topic": _topic,
		"player_dajare": _player_dajare,
		"enemy_dajare": _enemy_dajare
	})

	# POSTリクエストを送信する
	var headers: PackedStringArray = ["Content-Type: application/json"]
	var error: int = _http_request.request(_proxy_url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		DebugLogger.error("HTTPリクエストの送信に失敗しました: %s" % error, DebugCategories.Category.BATTLE_JUDGE)
		return {}

	# レスポンスが返るまで待機する
	var response: Array = await _http_request.request_completed

	if response[1] != 200:
		DebugLogger.error("プロキシサーバーからエラーが返りました: %s" % response[1], DebugCategories.Category.BATTLE_JUDGE)
		return {}

	var result: Dictionary = JSON.parse_string(response[3].get_string_from_utf8())
	if result == null:
		DebugLogger.error("レスポンスのJSONパースに失敗しました", DebugCategories.Category.BATTLE_JUDGE)
		return {}

	return result


# --- プライベートメソッド ---

## 設定ファイルからプロキシURLを読み込む。
func _load_config() -> void:
	var config := ConfigFile.new()
	var err: int = config.load("res://config/config.cfg")
	if err != OK:
		DebugLogger.error("設定ファイルを読み込めません: res://config/config.cfg", DebugCategories.Category.BATTLE_JUDGE)
		return
	_proxy_url = config.get_value("api", "proxy_url", "")
