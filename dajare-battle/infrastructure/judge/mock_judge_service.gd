extends JudgeServiceBase

## モックジャッジサービス。
##
## AIを使わず、ランダムなスコアを返す偽の判定サービス。
## 実際のAPIが使えない開発中のバトルループ検証に使用する。
## 戻り値の構造はJudgeServiceBaseを参照。
class_name MockJudgeService


## ランダムスコアを返す。0〜100の乱数をプレイヤー・敵それぞれに生成する。
func judge(_topic: String, _player_dajare: String, _enemy_dajare: String) -> Dictionary:
	await Engine.get_main_loop().process_frame
	return {
		"player_score": randi_range(0, 100),
		"enemy_score": randi_range(0, 100),
		"reason": "モック判定"
	}
