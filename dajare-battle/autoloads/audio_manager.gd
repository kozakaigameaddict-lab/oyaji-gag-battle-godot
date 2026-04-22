extends Node

## オーディオマネージャー
##
## ゲーム全体のBGM・SFX再生を一元管理するAutoloadクラス。
## 音声の再生は必ずこのクラスを経由する。
## 直接 AudioStreamPlayer を操作してはいけない。
##
## ※ BGMのループ設定・音量管理はPhase 7で実装予定。
##
## 使い方:
##   BGM再生: AudioManager.play_bgm("battle_bgm.ogg")
##   BGM停止: AudioManager.stop_bgm()
##   SFX再生: AudioManager.play_sfx("door_open.ogg")
class_name AudioManager

# オーディオファイルのベースパス
const _AUDIO_BASE_PATH: String = "res://assets/audio/"

# BGM再生用プレイヤー
var _bgm_player: AudioStreamPlayer
# SFX再生用プレイヤー (ワンショット再生)
var _sfx_player: AudioStreamPlayer


## 初期化: BGM・SFX用のAudioStreamPlayerをそれぞれ生成してシーンツリーに追加する
func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	add_child(_bgm_player)
	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)


## BGMを読み込んで再生する。
## pathはres://assets/audio/からの相対パス・拡張子込みで渡す。
## 例: "battle_bgm.ogg"
func play_bgm(path: String) -> void:
	var full_path: String = _AUDIO_BASE_PATH + path
	if path.is_empty() or not ResourceLoader.exists(full_path):
		DebugLogger.error("[AudioManager] 無効なBGMパスです: %s" % full_path)
		return
	_bgm_player.stream = load(full_path)
	# TODO: Phase 7 でループ設定を実装する (フォーマットにより設定方法が異なる)
	_bgm_player.play()


## BGMを停止し、ストリームを解放する。
func stop_bgm() -> void:
	_bgm_player.stop()
	_bgm_player.stream = null


## SFXを読み込んでワンショット再生する。
## pathはres://assets/audio/からの相対パス・拡張子込みで渡す。
## 例: "door_open.ogg"
func play_sfx(path: String) -> void:
	var full_path: String = _AUDIO_BASE_PATH + path
	if path.is_empty() or not ResourceLoader.exists(full_path):
		DebugLogger.error("[AudioManager] 無効なSFXパスです: %s" % full_path)
		return
	_sfx_player.stream = load(full_path)
	_sfx_player.play()
