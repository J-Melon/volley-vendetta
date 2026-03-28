class_name ProgressionData
extends RefCounted

var friendship_point_balance := 0
var upgrade_levels: Dictionary[String, int]
var high_score := 0


func save() -> bool:
	return true


func load() -> bool:
	return true
