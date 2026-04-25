extends Node

## セーブマネージャー
##
## ゲーム全体のセーブデータを一元管理するAutoloadクラス。
## データはGodot組み込みの暗号化ファイルに保存する。
## セーブファイルが存在しない場合（初回プレイ時）はデフォルト値で初期化する。
##
## 使い方：
##   セーブ:              SaveManager.save_data()
##   ロード:              SaveManager.load_data()  ← _ready()で自動実行
##   アンロック確認:      SaveManager.is_chapter_unlocked(1)
##   チャプター解禁:      SaveManager.unlock_chapter(2)
##
## ※ AutoloadにはGodotの制約によりclass_nameを付けない。

# --- 定数 ---

# セーブデータの暗号化パスワード（本番環境ではconfigファイルから読み込む予定）
const _SAVE_PASSWORD: String = "placeholder"

# セーブファイルの保存先 (user:// はGodotが管理するユーザーデータフォルダ)
const _SAVE_DATA_PATH: String = "user://save.dat"

# セーブデータのキー定数（辞書のキー名をハードコードしないための定数）
const _UNLOCKED_CHAPTERS: String = "unlocked_chapters"


# --- プライベート変数 ---

# メモリ上のセーブデータ。load_data()で読み込まれる。
var _save_data: Dictionary = {
	_UNLOCKED_CHAPTERS: [1]
}


# --- ライフサイクル ---

## 起動時にセーブデータを自動ロードする。
func _ready() -> void:
	load_data()


# --- パブリックメソッド ---

## 現在の_save_dataを暗号化ファイルに書き込む。
func save_data() -> void:
	var file = FileAccess.open_encrypted_with_pass(_SAVE_DATA_PATH, FileAccess.WRITE, _SAVE_PASSWORD)
	if file == null:
		DebugLogger.error("セーブファイルを開けませんでした: %s" % _SAVE_DATA_PATH)
		return
	file.store_string(JSON.stringify(_save_data))
	file.close()
	DebugLogger.debug("セーブしました")


## 暗号化ファイルからセーブデータを読み込む。
## ファイルが存在しない場合（初回プレイ）はデフォルト値をそのまま使用する。
func load_data() -> void:
	if not FileAccess.file_exists(_SAVE_DATA_PATH):
		DebugLogger.debug("セーブデータが見つかりません。初期値を使用します。")
		return
	var file = FileAccess.open_encrypted_with_pass(_SAVE_DATA_PATH, FileAccess.READ, _SAVE_PASSWORD)
	if file == null:
		DebugLogger.error("セーブファイルを開けませんでした: %s" % _SAVE_DATA_PATH)
		return
	_save_data = JSON.parse_string(file.get_as_text())
	file.close()
	DebugLogger.debug("ロードしました")


## 指定したチャプターが解禁済みかどうかを返す。
func is_chapter_unlocked(chapter_id: int) -> bool:
	return _save_data[_UNLOCKED_CHAPTERS].has(chapter_id)


## チャプターを解禁してセーブする。
## すでに解禁済みの場合は何もしない。
func unlock_chapter(chapter_id: int) -> void:
	if is_chapter_unlocked(chapter_id):
		return
	_save_data[_UNLOCKED_CHAPTERS].append(chapter_id)
	save_data()
