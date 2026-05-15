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
##   var result: Dictionary = judge.judge(topic, dajare)
##
## 戻り値のDictionary構造:
##   {
##       "pun_score":       int,    # ダジャレの完成度
##       "cold_score":      int,    # 寒さ・おやじ度
##       "scene_score":     int,    # 情景のシュールさ
##       "addictive_score": int,    # 既出度と余韻
##       "penalty":         int,    # カテゴリーペナルティ（0 or 50）
##       "comment":         String  # 判定コメント
##   }
class_name JudgeServiceBase


## だじゃれを判定してスコアを返す。
## このクラスでは空のデフォルト値を返す。
## 具象クラスでオーバーライドして実際のAI判定を実装すること。
func judge(_topic: String, _dajare: String) -> Dictionary:
	await Engine.get_main_loop().process_frame
	return {
		"pun_score": 0,
		"cold_score": 0,
		"scene_score": 0,
		"addictive_score": 0,
		"penalty": 0,		
		"comment": ""
	}
