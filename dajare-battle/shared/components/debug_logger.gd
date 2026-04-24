## デバッグログユーティリティ
##
## リリースビルドでデバッグログを自動的に無効化するラッパークラス。
## OS.is_debug_build() が false のとき（リリースエクスポート時）、
## debug() と warn() は何も出力しない。
## error() は常に出力する（重大なエラーはリリースでも記録が必要なため）。
##
## 使い方:
##   DebugLogger.debug("処理完了")
##   DebugLogger.warn("予期しない状態です")
##   DebugLogger.error("致命的なエラーが発生しました")
class_name DebugLogger


## デバッグログを出力する。リリースビルドでは無効。
static func debug(message: String) -> void:
	if OS.is_debug_build():
		print(message)


## 警告ログを出力する。リリースビルドでは無効。
static func warn(message: String) -> void:
	if OS.is_debug_build():
		push_warning(message)


## エラーログを出力する。デバッグ・リリース問わず常に出力する。
static func error(message: String) -> void:
	push_error(message)
