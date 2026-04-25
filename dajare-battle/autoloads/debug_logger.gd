extends Node

## デバッグログユーティリティ
##
## リリースビルドでデバッグログを自動的に無効化するラッパークラス。
## カテゴリ単位でログの出力を制御できる（ブラックリスト方式）。
## カテゴリは DebugCategories.Category で定義する。新しいカテゴリを追加する場合は
## debug_categories.gd のみ編集すればよい。
##
## 使い方:
##   DebugLogger.debug("TALKステートに遷移", DebugCategories.Category.BATTLE_MAIN)
##   DebugLogger.warn("ファイルが見つかりません", DebugCategories.Category.SAVE)
##   DebugLogger.error("無効なパスです", DebugCategories.Category.SCENE_MANAGER)
##
## カテゴリのミュート:
##   DebugLogger.mute(DebugCategories.Category.BATTLE_MAIN)    # カテゴリを非表示にする
##   DebugLogger.unmute(DebugCategories.Category.BATTLE_MAIN)  # 再び表示する
##
## ※ AutoloadにはGodotの制約によりclass_nameを付けない。


# --- エクスポート変数 ---

## Inspectorからミュートするスクリプトを登録できる（ブラックリスト方式）。
## 空 = すべてのスクリプトを出力する。
@export var muted_scripts: Array[String]
## Inspectorからミュートするカテゴリを登録できる（ブラックリスト方式）。
## 空 = すべてのカテゴリを出力する。
@export var muted_categories: Array[DebugCategories.Category]

# --- パブリックメソッド ---

## 指定カテゴリのデバッグログを無効化する。
func mute(category: DebugCategories.Category) -> void:
	if not muted_categories.has(category):
		muted_categories.append(category)


## 指定カテゴリのデバッグログを再び有効化する。
func unmute(category: DebugCategories.Category) -> void:
	muted_categories.erase(category)


## デバッグログを出力する。リリースビルドおよびミュート中のカテゴリでは無効。
func debug(message: String, category: DebugCategories.Category = DebugCategories.Category.NONE) -> void:
	if not OS.is_debug_build():
		return
	if _is_muted_script() or _is_muted_category(category):
		return
	var prefix: String = _get_caller_info()
	print("[%s] [%s] %s" % [prefix, DebugCategories.category_name(category), message])


## 警告ログを出力する。リリースビルドおよびミュート中のカテゴリでは無効。
func warn(message: String, category: DebugCategories.Category = DebugCategories.Category.NONE) -> void:
	if not OS.is_debug_build():
		return
	if _is_muted_script() or _is_muted_category(category):
		return
	var prefix: String = _get_caller_info()
	push_warning("[%s] [%s] %s" % [prefix, DebugCategories.category_name(category), message])


## エラーログを出力する。デバッグ・リリース問わず常に出力する。カテゴリのミュートも無視する。
func error(message: String, category: DebugCategories.Category = DebugCategories.Category.NONE) -> void:
	if OS.is_debug_build():
		var prefix: String = _get_caller_info()
		push_error("[%s] [%s] %s" % [prefix, DebugCategories.category_name(category), message])
		return
	else:
		push_error("[%s] %s" % [DebugCategories.category_name(category), message])


# --- プライベートメソッド ---

## 呼び出し元のスクリプト名と行番号を "ファイル名:行番号" 形式で返す。
## get_stack()[2] はこのメソッドを呼んだ public メソッド（debug/warn/error）の
## 呼び出し元を指す（index 0=本関数, 1=debug等, 2=実際の呼び出し元）。
func _get_caller_info() -> String:
	var stack: Array = get_stack()
	var source: String = stack[2]["source"].get_file()
	var line: int = stack[2]["line"]
	return "%s:%s" % [source, line]


## 呼び出し元スクリプトが muted_scripts に含まれているか判定する。
func _is_muted_script() -> bool:
	var stack: Array = get_stack()
	var script_name: String = stack[2]["source"].get_file()
	return muted_scripts.has(script_name)


## 指定カテゴリが muted_categories に含まれているか判定する。
func _is_muted_category(category_name: DebugCategories.Category) -> bool:
	return muted_categories.has(category_name)

