## ゲーム全体で使用する定数の一元管理クラス。
## 定数はこのクラスにまとめて定義し、各スクリプトからはここを参照する。
## 使い方: GameConstants.MAX_ROUNDS
class_name GameConstants


# --- バトル ---
## 1バトルの最大ラウンド数
const MAX_ROUNDS: int = 5
## 勝利に必要なラウンド勝利数
const WINS_REQUIRED: int = 3
