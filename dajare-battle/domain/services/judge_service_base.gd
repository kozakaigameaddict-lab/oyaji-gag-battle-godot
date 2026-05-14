extends RefCounted

## AIジャッジサービスの基底クラス。
##
## Claude・OpenAI・Gemini など各AIサービスの具象クラスはこのクラスを継承し、
## judge() メソッドをオーバーライドして実装する。
## ゲームロジックはこの基底クラスを通じてのみジャッジサービスを呼び出す。
## 具体的な実装クラスへの直接依存は禁止する。
##
## 使い方:
##   var judge: JudgeServiceBase = ServiceLocator.get_service("judge_service")
##   var result: Dictionary = judge.judge(topic, player_dajare, enemy_dajare)
##
## 戻り値のDictionary構造:
##   {
##       "player_score": int,   # プレイヤーのスコア
##       "enemy_score":  int,   # 敵のスコア
##       "reason":       String # 判定理由
##   }
class_name JudgeServiceBase


## だじゃれを判定してスコアを返す。
## このクラスでは空のデフォルト値を返す。
## 具象クラスでオーバーライドして実際のAI判定を実装すること。
func judge(_topic: String, _player_dajare: String, _enemy_dajare: String) -> Dictionary:
	await Engine.get_main_loop().process_frame
	return {
		"player_score": 0,
		"enemy_score": 0,
		"reason": ""
	}
