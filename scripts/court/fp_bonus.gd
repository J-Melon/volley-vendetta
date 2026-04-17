extends Label

@export var court: Court


func _ready() -> void:
	court.partner_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var percentage_offset: float = ItemManager.get_percentage_offset(&"friendship_points_per_hit")
	if percentage_offset > 0.0:
		text = "+%.0f%% FP" % (percentage_offset * 100)
		visible = true
	else:
		visible = false
