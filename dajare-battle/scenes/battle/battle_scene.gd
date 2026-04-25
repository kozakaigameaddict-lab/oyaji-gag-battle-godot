extends Node2D
class_name BattleScene

## バトルシーン
##
## バトルの進行を制御するスクリプト。
## 定数は GameConstants を参照すること。


# --- 列挙型 ---

enum BattleState {
	TALK,
	MAIN,
	PLAYER_PRESENTATION,
	ENEMY_PRESENTATION,
	JUDGE,
	FRIEND_COMMENT,
}


# --- プライベート変数 ---

var _current_state: BattleState
var _current_round: int = 0
var _player_win_count: int = 0
var _enemy_win_count: int = 0


# --- ライフサイクル ---

## 起動時にカウンターを初期化し、TALKステートから開始する。
func _ready() -> void:
	_current_round = 0
	_player_win_count = 0
	_enemy_win_count = 0
	_change_state(BattleState.TALK)


# --- パブリックメソッド ---

## ラウンド間のリセット処理。次のラウンド開始前に呼び出す。
func initialize() -> void:
	pass


# --- プライベートメソッド ---

## 指定ステートに切り替えて対応する _enter_* を呼び出す。
func _change_state(new_state: BattleState) -> void:
	_current_state = new_state
	match _current_state:
		BattleState.TALK:
			_enter_talk()
		BattleState.MAIN:
			_enter_main()
		BattleState.PLAYER_PRESENTATION:
			_enter_player_presentation()
		BattleState.ENEMY_PRESENTATION:
			_enter_enemy_presentation()
		BattleState.JUDGE:
			_enter_judge()
		BattleState.FRIEND_COMMENT:
			_enter_friend_comment()


## TALKステートの開始処理。
func _enter_talk() -> void:
	DebugLogger.debug("TALKへ入場した", DebugCategories.Category.BATTLE_MAIN)


## MAINステートの開始処理。
func _enter_main() -> void:
	DebugLogger.debug("MAINへ入場した", DebugCategories.Category.BATTLE_MAIN)


## PLAYER_PRESENTATIONステートの開始処理。
func _enter_player_presentation() -> void:
	DebugLogger.debug("PLAYER_PRESENTATIONへ入場した", DebugCategories.Category.BATTLE_PRESENTATION)


## ENEMY_PRESENTATIONステートの開始処理。
func _enter_enemy_presentation() -> void:
	DebugLogger.debug("ENEMY_PRESENTATIONへ入場した", DebugCategories.Category.BATTLE_PRESENTATION)


## JUDGEステートの開始処理。
func _enter_judge() -> void:
	DebugLogger.debug("JUDGEへ入場した", DebugCategories.Category.BATTLE_JUDGE)


## FRIEND_COMMENTステートの開始処理。
func _enter_friend_comment() -> void:
	DebugLogger.debug("FRIEND_COMMENTへ入場した", DebugCategories.Category.BATTLE_MAIN)
