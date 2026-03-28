extends Node

const PADDLE_SPEED_KEY := "paddle_speed"
const PADDLE_SIZE_KEY := "paddle_size"
const BALL_SPEED_MIN_KEY := "ball_speed_min"

var upgrades: Array[Upgrade]
var _progression: ProgressionData


func _ready():
	_progression = ProgressionData.new()


## Returns total cost of [Upgrade] based on current level
func calculate_cost(upgrade_key: String) -> int:
	var upgrade := _get_upgrade(upgrade_key)
	return int(upgrade.base_cost * pow(upgrade.cost_scaling, get_level(upgrade.id)))


## Returns current level of [Upgrade]
func get_level(upgrade_id: String) -> int:
	assert(
		upgrades.any(func(upgrade: Upgrade) -> bool: return upgrade.id == upgrade_id),
		"Unknown upgrade id: %s" % upgrade_id
	)
	return _progression.upgrade_levels.get(upgrade_id, 0)


## Purchases [Upgrade] based on cost and max level, level++
func purchase(upgrade_key: String) -> bool:
	var upgrade := _get_upgrade(upgrade_key)

	if can_purchase(upgrade_key):
		_progression.friendship_point_balance -= calculate_cost(upgrade_key)
		_increment_level(upgrade.id)
		return true

	return false


## Returns if there are enough friendship points to puchase an [Upgrade]
func can_purchase(upgrade_key: String) -> bool:
	var upgrade := _get_upgrade(upgrade_key)

	if (
		_progression.friendship_point_balance >= calculate_cost(upgrade_key)
		and get_level(upgrade.id) < upgrade.max_level
	):
		return true

	return false


## Returns total value of an [Upgrade] for its current level
func get_value(upgrade_key: String) -> float:
	var upgrade := _get_upgrade(upgrade_key)
	var upgraded_value := 0.0

	upgraded_value = upgrade.base_value
	upgraded_value += _calculate_modifier(upgrade)

	return upgraded_value


func _get_upgrade(key: String) -> Upgrade:
	assert(
		upgrades.any(func(upgrade: Upgrade) -> bool: return upgrade.effect_key == key),
		"Unknown effect key: %s" % key
	)

	for upgrade: Upgrade in upgrades:
		if upgrade.effect_key == key:
			return upgrade

	return null


func _calculate_modifier(upgrade: Upgrade) -> float:
	return upgrade.effect_per_level * get_level(upgrade.id)


func _increment_level(upgrade_id: String) -> void:
	_progression.upgrade_levels[upgrade_id] = get_level(upgrade_id) + 1
