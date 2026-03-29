extends VBoxContainer

var _buttons: Dictionary = {}


func _ready() -> void:
	for upgrade in UpgradeManager.upgrades:
		var row := HBoxContainer.new()
		add_child(row)

		var buy_button := Button.new()
		buy_button.pressed.connect(_on_upgrade_pressed.bind(upgrade.key))
		buy_button.focus_mode = Control.FOCUS_NONE
		buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(buy_button)
		_buttons[upgrade.key] = buy_button

		var remove_button := Button.new()
		remove_button.text = "-"
		remove_button.pressed.connect(_on_remove_level_pressed.bind(upgrade.key))
		remove_button.focus_mode = Control.FOCUS_NONE
		row.add_child(remove_button)
	_refresh_buttons()

	_friendship_point_balance_booster()


func _on_upgrade_pressed(upgrade_key: String) -> void:
	UpgradeManager.purchase(upgrade_key)
	_refresh_buttons()


func _on_remove_level_pressed(upgrade_key: String) -> void:
	UpgradeManager.remove_level(upgrade_key)
	_refresh_buttons()


func _refresh_buttons() -> void:
	for upgrade in UpgradeManager.upgrades:
		var button: Button = _buttons[upgrade.key]
		var level := UpgradeManager.get_level(upgrade.key)
		var cost := UpgradeManager.calculate_cost(upgrade.key)
		button.text = "%s Lv%d [%d FP]" % [upgrade.display_name, level, cost]
		button.disabled = not UpgradeManager.can_purchase(upgrade.key)


func _friendship_point_balance_booster() -> void:
	var friendship_point_input := SpinBox.new()
	friendship_point_input.value = 100
	friendship_point_input.min_value = 1
	friendship_point_input.max_value = 10000
	friendship_point_input.step = 10
	friendship_point_input.focus_mode = Control.FOCUS_NONE
	add_child(friendship_point_input)

	var friendship_point_button := Button.new()
	friendship_point_button.text = "Add FP"
	friendship_point_button.focus_mode = Control.FOCUS_NONE
	friendship_point_button.pressed.connect(
		_on_friendship_point_balance_booster_pressed.bind(friendship_point_input)
	)
	add_child(friendship_point_button)

	var remove_friendship_point_button := Button.new()
	remove_friendship_point_button.text = "Remove FP"
	remove_friendship_point_button.focus_mode = Control.FOCUS_NONE
	remove_friendship_point_button.pressed.connect(
		_on_remove_friendship_point_pressed.bind(friendship_point_input)
	)
	add_child(remove_friendship_point_button)


func _on_friendship_point_balance_booster_pressed(input: SpinBox) -> void:
	UpgradeManager.add_friendship_points(int(input.value))
	_refresh_buttons()


func _on_remove_friendship_point_pressed(input: SpinBox) -> void:
	UpgradeManager.subtract_friendship_points(int(input.value))
	_refresh_buttons()
