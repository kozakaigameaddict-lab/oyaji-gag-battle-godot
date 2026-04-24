extends GutTest

## ServiceLocator のユニットテスト。
##
## Autoloadインスタンスではなく、スクリプトから直接生成した
## 独立したインスタンスを使用することでテストを分離する。


# テスト対象のServiceLocatorインスタンス
var _locator: Node


## 前処理: テストごとにクリーンなServiceLocatorを生成する。
func before_each() -> void:
	_locator = load("res://autoloads/service_locator.gd").new()


## 後処理: メモリリークを防ぐためインスタンスを解放する。
func after_each() -> void:
	_locator.free()


## register() で登録したサービスが get_service() で取得できること。
func test_register() -> void:
	_locator.register("judge_service", MockJudgeService.new())
	var judge: Object = _locator.get_service("judge_service")
	assert_true(judge is MockJudgeService)


## 存在しないキーで get_service() を呼ぶと null が返ること。
func test_get_service_unknown_key_returns_null() -> void:
	var unknown: Object = _locator.get_service("unknown")
	assert_null(unknown)


## register() 後に has_service() が true を返すこと。
func test_has_service_returns_true_after_register() -> void:
	_locator.register("judge_service", MockJudgeService.new())
	assert_true(_locator.has_service("judge_service"))


## 未登録のキーで has_service() が false を返すこと。
func test_has_service_returns_false_for_unknown_key() -> void:
	assert_false(_locator.has_service("unknown"))
