class_name DebugCategories

## デバッグログで使用するカテゴリの一覧。
## 新しいカテゴリが必要な場合はこのファイルの Category enum にのみ追加する。
## debug_logger.gd を編集する必要はない。


# --- 列挙型 ---

# ログカテゴリ。スクリプトの役割単位で分類する。
enum Category {
	NONE,
	BATTLE_MAIN,
	BATTLE_PRESENTATION,
	BATTLE_JUDGE,
	SAVE,
	SCENE_MANAGER,
	AUDIO,
}


# --- パブリックメソッド ---

## カテゴリの enum 値を文字列名に変換して返す。
## 例: Category.BATTLE_MAIN → "BATTLE_MAIN"
static func category_name(category: Category) -> String:
	return Category.find_key(category)
