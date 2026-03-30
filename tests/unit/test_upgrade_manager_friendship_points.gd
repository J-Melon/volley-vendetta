extends GutTest

# Tests for UpgradeManager friendship point balance methods:
# get_friendship_point_balance, add_friendship_points, subtract_friendship_points.

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


# --- get_friendship_point_balance ---
func test_get_friendship_point_balance_returns_current_balance() -> void:
	_manager._progression.friendship_point_balance = 250
	assert_eq(_manager.get_friendship_point_balance(), 250)


# --- add_friendship_points ---
func test_add_friendship_points_increases_balance() -> void:
	_manager.add_friendship_points(50)
	assert_eq(_manager.get_friendship_point_balance(), 50)


func test_add_friendship_points_emits_signal() -> void:
	watch_signals(_manager)
	_manager.add_friendship_points(75)
	assert_signal_emitted_with_parameters(_manager, "friendship_point_balance_changed", [75])


# --- subtract_friendship_points ---
func test_subtract_friendship_points_decreases_balance() -> void:
	_manager._progression.friendship_point_balance = 200
	_manager.subtract_friendship_points(80)
	assert_eq(_manager.get_friendship_point_balance(), 120)


func test_subtract_friendship_points_clamps_to_zero() -> void:
	_manager._progression.friendship_point_balance = 30
	_manager.subtract_friendship_points(100)
	assert_eq(_manager.get_friendship_point_balance(), 0)


func test_subtract_friendship_points_emits_signal() -> void:
	_manager._progression.friendship_point_balance = 100
	watch_signals(_manager)
	_manager.subtract_friendship_points(40)
	assert_signal_emitted_with_parameters(_manager, "friendship_point_balance_changed", [60])
