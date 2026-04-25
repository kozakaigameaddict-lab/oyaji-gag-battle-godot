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

# --- ノード参照 ---

@onready var _topic_label: Label = $MainLayer/TopicLabel
@onready var _dajare_input: LineEdit = $MainLayer/DajareInput
@onready var _submit_button: Button = $MainLayer/SubmitButton
@onready var _timer: Timer = $MainLayer/Timer
@onready var _player_dajare_label: Label = $MainLayer/PlayerDajareLabel
@onready var _enemy_dajare_label: Label = $MainLayer/EnemyDajareLabel
@onready var _next_button: Button = $MainLayer/NextButton
@onready var _player_score_label: Label = $MainLayer/PlayerScoreLabel
@onready var _enemy_score_label: Label = $MainLayer/EnemyScoreLabel


# --- プライベート変数 ---

var _current_state: BattleState
var _current_round: int = 0
var _player_win_count: int = 0
var _enemy_win_count: int = 0
var _player_dajare: String = ""
var _enemy_dajare: String = ""
var _player_score: int = 0
var _enemy_score: int = 0
var _winner: String = ""
var _topic: String = "テスト"


# --- ライフサイクル ---

## 起動時にカウンターを初期化し、TALKステートから開始する。
func _ready() -> void:
	_submit_button.pressed.connect(_on_submit_pressed)
	_next_button.pressed.connect(_on_next_pressed)
	_current_round = 0
	_player_win_count = 0
	_enemy_win_count = 0
	_change_state(BattleState.TALK)


# --- パブリックメソッド ---

## ラウンド間のリセット処理。次のラウンド開始前に呼び出す。
## データの初期化のみに使用すること
func initialize() -> void:
	_current_round += 1
	_player_dajare = ""
	_enemy_dajare = ""
	_player_score = 0
	_enemy_score = 0


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
	DebugLogger.debug("TALKへ入場した", DebugCategories.Category.BATTLE_TALK)


## MAINステートの開始処理。
func _enter_main() -> void:
	DebugLogger.debug("MAINへ入場した", DebugCategories.Category.BATTLE_MAIN)
	initialize()
	_topic_label.text = _topic
	_dajare_input.text = ""
	_dajare_input.grab_focus()
	_timer.start(30.0)


## PLAYER_PRESENTATIONステートの開始処理。
func _enter_player_presentation() -> void:
	DebugLogger.debug("PLAYER_PRESENTATIONへ入場した", DebugCategories.Category.BATTLE_PRESENTATION)
	_player_dajare_label.text = _player_dajare


## ENEMY_PRESENTATIONステートの開始処理。
func _enter_enemy_presentation() -> void:
	DebugLogger.debug("ENEMY_PRESENTATIONへ入場した", DebugCategories.Category.BATTLE_PRESENTATION)
	_enemy_dajare = "ダジャレのサンプル"
	_enemy_dajare_label.text = _enemy_dajare


## JUDGEステートの開始処理。
func _enter_judge() -> void:
	DebugLogger.debug("JUDGEへ入場した", DebugCategories.Category.BATTLE_JUDGE)
	var judge_service: JudgeServiceBase = ServiceLocator.get_service("judge_service")
	if judge_service == null:
		DebugLogger.error("judge_serviceが登録されていません", DebugCategories.Category.BATTLE_JUDGE)
		return
	var result: Dictionary = judge_service.judge(_topic, _player_dajare, _enemy_dajare)
	_player_score = result["player_score"]
	_player_score_label.text = str(_player_score)
	_enemy_score = result["enemy_score"]
	_enemy_score_label.text = str(_enemy_score)
	DebugLogger.debug("結果: %s" % str(result), DebugCategories.Category.BATTLE_JUDGE)
	

## FRIEND_COMMENTステートの開始処理。
func _enter_friend_comment() -> void:
	DebugLogger.debug("FRIEND_COMMENTへ入場した", DebugCategories.Category.BATTLE_FRIEND_COMMENT)


## 送信ボタンが押されたときの処理
func _on_submit_pressed() -> void:
	_player_dajare = _dajare_input.text.strip_edges()
	if _player_dajare.is_empty():
		return
	_timer.stop()
	DebugLogger.debug("ダジャレを送信: %s" % _player_dajare, DebugCategories.Category.BATTLE_MAIN)
	_change_state(BattleState.PLAYER_PRESENTATION)


## Nextボタンが押されたときの処理
func _on_next_pressed() -> void:
	match _current_state:
		BattleState.TALK:
			_change_state(BattleState.MAIN)
		BattleState.PLAYER_PRESENTATION:
			_change_state(BattleState.ENEMY_PRESENTATION)
		BattleState.ENEMY_PRESENTATION:
			_change_state(BattleState.JUDGE)
		BattleState.JUDGE:
			_change_state(BattleState.FRIEND_COMMENT)			
		BattleState.FRIEND_COMMENT:
			if _resolve_round():
				DebugLogger.debug(
					"バトル終了: 勝者[%s], プレイヤー勝ち点[%s], エネミー勝ち点[%s], " % [_winner, _player_win_count, _enemy_win_count], 
					DebugCategories.Category.BATTLE_FRIEND_COMMENT)
			else:
				_change_state(BattleState.TALK)


## 勝敗の判定を行う
func _resolve_round() -> bool:
	if _player_score >= _enemy_score:
		_player_win_count += 1
	else: 
		_enemy_win_count += 1
	if _player_win_count >= GameConstants.WINS_REQUIRED:
		_winner = "プレイヤー"
		return true
	elif _enemy_win_count >= GameConstants.WINS_REQUIRED:
		_winner = "エネミー"
		return true
	return false