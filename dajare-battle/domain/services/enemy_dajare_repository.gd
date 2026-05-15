extends Node
class_name EnemyDajareRepository

var _enemy_dajare_data_path: String = "res://domain/data/enemy_dajare.csv"
var _enemy_dajare_list: Array[EnemyDajareData] = []

func _ready() -> void:
	var file = FileAccess.open(_enemy_dajare_data_path, FileAccess.READ)
	if file == null:
		DebugLogger.error("CSVファイルを開けません", DebugCategories.Category.NONE)
		return
	file.get_csv_line()

	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < 8:
			continue
		var data = EnemyDajareData.new()
		data.topic = row[0]
		data.dajare = row[1]
		data.pun_score = int(row[2])
		data.cold_score = int(row[3])
		data.scene_score = int(row[4])
		data.addictive_score = int(row[5])
		data.speed_score = int(row[6])
		data.penalty = int(row[7])		
		_enemy_dajare_list.append(data)

func get_random_by_topic(topic: String) -> EnemyDajareData:
	var filtered: Array = _enemy_dajare_list.filter(
		func(d): return d.topic == topic
	)
	if filtered.is_empty():
		return null
	return filtered.pick_random()

func get_all_topics() -> Array[String]:
	var topics: Array[String] = []
	for data in _enemy_dajare_list:
		if not topics.has(data.topic):
			topics.append(data.topic)
	return topics