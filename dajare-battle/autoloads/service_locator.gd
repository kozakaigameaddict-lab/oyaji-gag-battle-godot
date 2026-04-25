extends Node

## サービスロケーター
##
## ゲーム全体で使用するサービス（依存オブジェクト）を一元管理するAutoloadクラス。
## 各システムは直接依存先をインスタンス化せず、このクラスを通じて取得する。
## これにより、実装の差し替え（例: AIサービスの切り替え）が容易になる。
##
## 使い方:
##   登録: ServiceLocator.register("judge_service", ClaudeJudgeService.new())
##   取得: var judge = ServiceLocator.get_service("judge_service")
##   削除: ServiceLocator.unregister("judge_service")
##
## ※ AutoloadにはGodotの制約によりclass_nameを付けない。

# --- プライベート変数 ---

# 登録されたサービスを保持する辞書 (key: String, value: Object)
var _services: Dictionary = {}


# --- パブリックメソッド ---

## サービスを登録する。
## すでに同じキーで登録済みの場合は警告を出して何もしない。
func register(key: String, service: Object) -> void:
	if _services.has(key):
		DebugLogger.error("すでに登録済みのキーです: %s" % key)
		return
	_services[key] = service
	DebugLogger.debug("サービスを登録しました: %s" % key)


## サービスを取得する。
## キーが存在しない場合は警告を出してnullを返す。
func get_service(key: String) -> Object:
	if _services.has(key):
		return _services[key]
	DebugLogger.error("存在しないキーです: %s" % key)
	return null


## サービスの登録を解除する。
## キーが存在しない場合は警告を出す。
func unregister(key: String) -> void:
	if not _services.has(key):
		DebugLogger.error("登録されていないキーです: %s" % key)
		return
	_services.erase(key)
	DebugLogger.debug("サービスを削除しました: %s" % key)


## 指定したキーのサービスが登録済みかどうかを返す。
func has_service(key: String) -> bool:
	return _services.has(key)
