extends GutTest

# Tests for UpgradeManager: upgrade_level_changed signal and remove_level.

const SPEED_KEY := "test_speed"

var _manager: Node
var _mock_storage: SaveStorage


func before_each() -> void:
	var upgrade := Upgrade.new()
	upgrade.key = SPEED_KEY
	upgrade.base_value = 200.0
	upgrade.effect_per_level = 20.0
	upgrade.max_level = 3
	upgrade.base_cost = 100
	upgrade.cost_scaling = 2.0

	_mock_storage = double(SaveStorage).new()
	stub(_mock_storage.write).to_return(true)
	stub(_mock_storage.read).to_return("")

	_manager = load("res://scripts/progression/upgrade_manager.gd").new()
	_manager._progression = ProgressionData.new(_mock_storage)
	add_child_autofree(_manager)
	_manager.upgrades.assign([upgrade])


# --- upgrade_level_changed ---
func test_purchase_emits_upgrade_level_changed() -> void:
	_manager._progression.friendship_point_balance = 1000
	watch_signals(_manager)
	_manager.purchase(SPEED_KEY)
	assert_signal_emitted_with_parameters(_manager, "upgrade_level_changed", [SPEED_KEY])


func test_remove_level_emits_upgrade_level_changed() -> void:
	_manager._progression.friendship_point_balance = 1000
	_manager.purchase(SPEED_KEY)
	watch_signals(_manager)
	_manager.remove_level(SPEED_KEY)
	assert_signal_emitted_with_parameters(_manager, "upgrade_level_changed", [SPEED_KEY])


func test_remove_level_at_zero_does_not_emit() -> void:
	watch_signals(_manager)
	_manager.remove_level(SPEED_KEY)
	assert_signal_not_emitted(_manager, "upgrade_level_changed")


# --- remove_level ---
func test_remove_level_decrements_level() -> void:
	_manager._progression.friendship_point_balance = 1000
	_manager.purchase(SPEED_KEY)
	_manager.remove_level(SPEED_KEY)
	assert_eq(_manager.get_level(SPEED_KEY), 0)


func test_remove_level_does_nothing_at_zero() -> void:
	_manager.remove_level(SPEED_KEY)
	assert_eq(_manager.get_level(SPEED_KEY), 0)


func test_remove_level_allows_repurchase_after_max() -> void:
	_manager._progression.friendship_point_balance = 10000
	_manager.purchase(SPEED_KEY)
	_manager.purchase(SPEED_KEY)
	_manager.purchase(SPEED_KEY)
	assert_false(_manager.can_purchase(SPEED_KEY))
	_manager.remove_level(SPEED_KEY)
	assert_true(_manager.can_purchase(SPEED_KEY))
