extends Node

## ゲームイニシャライザー (Composition Root)
##
## ゲーム起動時にすべてのサービスをServiceLocatorへ登録する唯一の場所。
## このクラスだけが具象実装クラス（MockJudgeServiceなど）を直接参照することを許可する。
## 他のクラスは必ずServiceLocatorを経由してサービスを取得すること。
##
## ※ Project Settings → Autoload で必ず最後に登録すること。
##   他のAutoload（ServiceLocatorなど）が初期化された後に実行される必要があるため。
##
## ※ AutoloadにはGodotの制約によりclass_nameを付けない。


## 起動時にすべてのサービスをServiceLocatorへ登録する。
func _ready() -> void:
	# HTTPRequestノードを作り、サービスに渡す
	var http_pun = HTTPRequest.new()
	add_child(http_pun)
	var http_cold = HTTPRequest.new()
	add_child(http_cold)
	var http_scene = HTTPRequest.new()
	add_child(http_scene)
	var http_addictive = HTTPRequest.new()
	add_child(http_addictive)
	var http_penalty = HTTPRequest.new()
	add_child(http_penalty)
	var http_comment = HTTPRequest.new()
	add_child(http_comment)
	# AIジャッジサービス: 開発中はモックを使用。Phase 3でAPIサービスに切り替える。
	# AIジャッジ（本番用 - レート制限に注意）
	# ServiceLocator.register("judge_service", GeminiJudgeService.new(
	#     http_pun, http_cold, http_scene, http_addictive, http_penalty, http_comment))

	# モック（開発用）
	ServiceLocator.register("judge_service", MockJudgeService.new())	
	var repo = EnemyDajareRepository.new()
	add_child(repo)
	ServiceLocator.register("enemy_dajare_repository", repo)