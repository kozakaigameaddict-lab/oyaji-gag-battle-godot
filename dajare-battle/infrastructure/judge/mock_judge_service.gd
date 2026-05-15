extends JudgeServiceBase

## モックジャッジサービス。
##
## AIを使わず、ランダムなスコアを返す偽の判定サービス。
## 実際のAPIが使えない開発中のバトルループ検証に使用する。
## 戻り値の構造はJudgeServiceBaseを参照。
class_name MockJudgeService


## ランダムスコアを返す。各軸に0〜20の乱数、penaltyに0か50を生成する。
func judge(_topic: String, _dajare: String) -> Dictionary:
	await Engine.get_main_loop().process_frame
	return {
		"pun_score": randi_range(0, 20),
		"cold_score": randi_range(0, 20),
		"scene_score": randi_range(0, 20),
		"addictive_score": randi_range(0, 20),
		"penalty": randi() % 2 * 50,		
		"comment": "モック判定"
	}
