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
	var http_node = HTTPRequest.new()
	add_child(http_node)
	# AIジャッジサービス: 開発中はモックを使用。Phase 3でAPIサービスに切り替える。
	ServiceLocator.register("judge_service", GeminiJudgeService.new(http_node))
