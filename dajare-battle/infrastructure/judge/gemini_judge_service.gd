extends JudgeServiceBase
class_name GeminiJudgeService

## GeminiAPI経由のだじゃれ判定サービス。
## プロキシサーバー（Cloudflare Workers）を経由してGemini APIを呼び出す。
## APIキーはプロキシサーバー側で管理し、ゲーム内には保持しない。


# --- プライベート変数 ---

# HTTPリクエストを送受信するノード（外部から注入する）
var _http_pun: HTTPRequest
var _http_cold: HTTPRequest
var _http_scene: HTTPRequest
var _http_addictive: HTTPRequest
var _http_penalty: HTTPRequest
var _http_comment: HTTPRequest


# プロキシサーバーのURL（config/config.cfgから読み込む）
var _proxy_url: String = ""


# --- パブリックメソッド ---

## 依存するHTTPRequestノードを受け取り、設定ファイルからプロキシURLを読み込む。
func _init(
	http_pun: HTTPRequest,
	http_cold: HTTPRequest,
	http_scene: HTTPRequest,
	http_addictive: HTTPRequest,
	http_penalty: HTTPRequest,
	http_comment: HTTPRequest
	) -> void:
	_http_pun = http_pun
	_http_cold = http_cold
	_http_scene = http_scene
	_http_addictive = http_addictive
	_http_penalty = http_penalty
	_http_comment = http_comment
	_load_config()


## だじゃれを判定してスコアを返す。
## プロキシにPOSTリクエストを送り、Geminiの判定結果を受け取る。
func judge(topic: String, dajare: String) -> Dictionary:
	# 6つのリクエストを送信	
	_send_request(topic, dajare, "pun")
	_send_request(topic, dajare, "cold")
	_send_request(topic, dajare, "scene")
	_send_request(topic, dajare, "addictive")
	_send_request(topic, dajare, "penalty_check")
	_send_request(topic, dajare, "comment")
	
	# レスポンスが返るまで待機する
	var r_pun: Array = await _http_pun.request_completed
	var r_cold: Array = await _http_cold.request_completed
	var r_scene: Array = await _http_scene.request_completed
	var r_addictive: Array = await _http_addictive.request_completed
	var r_penalty: Array = await _http_penalty.request_completed
	var r_comment: Array = await _http_comment.request_completed
	
	var d_pun: Dictionary = _parse_response(r_pun)
	var d_cold: Dictionary = _parse_response(r_cold)
	var d_scene: Dictionary = _parse_response(r_scene)
	var d_addictive: Dictionary = _parse_response(r_addictive)
	var d_penalty: Dictionary = _parse_response(r_penalty)
	var d_comment: Dictionary = _parse_response(r_comment)
	
	# ペナルティの結果解析
	var contains_topic: bool = d_penalty.get("contains_topic", true)
	var penalty: int = 0 if contains_topic else GameConstants.CATEGORY_PENALTY_AMOUNT
	
	# 辞書型の結果生成
	var result: Dictionary = {
		"pun_score": int(d_pun.get("pun_score", 0)),
		"cold_score": int(d_cold.get("cold_score", 0)),
		"scene_score": int(d_scene.get("scene_score", 0)),
		"addictive_score": int(d_addictive.get("addictive_score", 0)),
		"penalty": penalty,
		"comment": d_comment.get("comment", "")
	}

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

## criterion別にAPIリクエストを実行する
func _send_request(topic: String, dajare: String, criterion :String) -> void:
	if _proxy_url.is_empty():
		DebugLogger.error("proxy_urlが設定されていません", DebugCategories.Category.BATTLE_JUDGE)
		return

	var headers: PackedStringArray = ["Content-Type: application/json"]

	# プロキシに送るJSONボディを組み立てる
	var body: String = JSON.stringify({
		"topic": topic,
		"dajare": dajare,
		"criterion": criterion
	})

	# criterionに合わせhttpサーバーを選択
	var http_request: HTTPRequest = null
	match criterion:
		"pun":
			http_request = _http_pun
		"cold":
			http_request = _http_cold
		"scene":
			http_request = _http_scene
		"addictive":
			http_request = _http_addictive
		"penalty_check":
			http_request = _http_penalty
		"comment":
			http_request = _http_comment
		_:
			return
		
	# POSTリクエストを送信する	
	var request: int = http_request.request(_proxy_url, headers, HTTPClient.METHOD_POST, body)
	
	if request != OK:
		DebugLogger.error("HTTPリクエストの送信に失敗しました: %s" % request, DebugCategories.Category.BATTLE_JUDGE)
		return


## APIから返却されたresponseを解析する
func _parse_response(response: Array) -> Dictionary:
	if response[1] != 200:
		DebugLogger.error("プロキシサーバーからエラーが返りました: %s" % response[1], DebugCategories.Category.BATTLE_JUDGE)
		return {}

	var result: Dictionary = JSON.parse_string(response[3].get_string_from_utf8())
	if result == null:
		DebugLogger.error("レスポンスのJSONパースに失敗しました", DebugCategories.Category.BATTLE_JUDGE)
		return {}

	return result