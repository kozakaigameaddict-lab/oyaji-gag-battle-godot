extends Node

## シーンマネージャー
##
## ゲーム全体のシーン遷移を一元管理するAutoloadクラス。
## シーンの切り替えはすべてこのクラスを経由する。
## 直接 get_tree().change_scene_to_file() を呼び出してはいけない。
##
## 使い方:
##   SceneManager.change_scene("title/title_scene")
class_name SceneManager

# シーンファイルのベースパス
const _SCENE_BASE_PATH: String = "res://scenes/"
const _SCENE_EXTENSION: String = ".tscn"


## シーンを切り替える。
## pathが空、またはファイルが存在しない場合はエラーを出して処理を中断する。
## pathはres://scenes/からの相対パス・拡張子なしで渡す。
## 例: "title/title_scene" → res://scenes/title/title_scene.tscn
func change_scene(path: String) -> void:
	var full_path: String = _SCENE_BASE_PATH + path + _SCENE_EXTENSION
	if path.is_empty() or not ResourceLoader.exists(full_path):
		DebugLogger.error("[SceneManager] 無効なシーンパスです: %s" % full_path)
		return
	get_tree().change_scene_to_file(full_path)
