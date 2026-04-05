class_name EffectState
extends RefCounted

var _base_values: Dictionary[StringName, float] = {}
var _add_modifiers: Array[StatModifier] = []
var _percentage_modifiers: Array[StatModifier] = []
var _multiply_modifiers: Array[StatModifier] = []
var _until_miss_add_modifiers: Array[StatModifier] = []
var _until_miss_percentage_modifiers: Array[StatModifier] = []
var _until_miss_multiply_modifiers: Array[StatModifier] = []
var _active_states: Dictionary[StringName, String] = {}
var _oscillations: Array[StatOscillation] = []


func get_stat(key: StringName) -> float:
	assert(_base_values.has(key), "EffectState: unregistered stat key: " + key)

	var result: float = _base_values[key]

	for oscillation in _oscillations:
		if oscillation.stat_key == key:
			result += oscillation.get_offset(self)

	for modifier in _add_modifiers:
		if modifier.stat_key == key:
			result += _resolve_value(modifier)

	for modifier in _until_miss_add_modifiers:
		if modifier.stat_key == key:
			result += _resolve_value(modifier)

	result *= _sum_percentage_multiplier(
		key, _percentage_modifiers, _until_miss_percentage_modifiers
	)

	for modifier in _multiply_modifiers:
		if modifier.stat_key == key:
			result *= _resolve_value(modifier)

	for modifier in _until_miss_multiply_modifiers:
		if modifier.stat_key == key:
			result *= _resolve_value(modifier)

	return result


func get_permanent_stat(key: StringName) -> float:
	assert(_base_values.has(key), "EffectState: unregistered stat key: " + key)

	var result: float = _base_values[key]

	for oscillation in _oscillations:
		if oscillation.stat_key == key:
			result += oscillation.get_offset(self)

	for modifier in _add_modifiers:
		if modifier.stat_key == key:
			result += _resolve_value(modifier)

	result *= _sum_percentage_multiplier(key, _percentage_modifiers)

	for modifier in _multiply_modifiers:
		if modifier.stat_key == key:
			result *= _resolve_value(modifier)

	return result


func add_modifier(modifier: StatModifier) -> void:
	match modifier.operation:
		StatModifier.Operation.ADD:
			_add_modifiers.append(modifier)
		StatModifier.Operation.PERCENTAGE:
			_percentage_modifiers.append(modifier)
		StatModifier.Operation.MULTIPLY:
			_multiply_modifiers.append(modifier)


func add_until_miss_modifier(modifier: StatModifier) -> void:
	match modifier.operation:
		StatModifier.Operation.ADD:
			_until_miss_add_modifiers.append(modifier)
		StatModifier.Operation.PERCENTAGE:
			_until_miss_percentage_modifiers.append(modifier)
		StatModifier.Operation.MULTIPLY:
			_until_miss_multiply_modifiers.append(modifier)


func clear_until_miss_modifiers() -> void:
	_until_miss_add_modifiers.clear()
	_until_miss_percentage_modifiers.clear()
	_until_miss_multiply_modifiers.clear()


func remove_modifiers_by_source(source_key: String) -> void:
	_add_modifiers = _add_modifiers.filter(_exclude_source.bind(source_key))
	_percentage_modifiers = _percentage_modifiers.filter(_exclude_source.bind(source_key))
	_multiply_modifiers = _multiply_modifiers.filter(_exclude_source.bind(source_key))
	_until_miss_add_modifiers = _until_miss_add_modifiers.filter(_exclude_source.bind(source_key))
	_until_miss_percentage_modifiers = _until_miss_percentage_modifiers.filter(
		_exclude_source.bind(source_key)
	)
	_until_miss_multiply_modifiers = _until_miss_multiply_modifiers.filter(
		_exclude_source.bind(source_key)
	)
	_oscillations = _oscillations.filter(
		func(oscillation: StatOscillation) -> bool: return oscillation.source_key != source_key
	)


func register_base_values(values: Dictionary) -> void:
	for key in values:
		_base_values[key] = values[key]


func add_oscillation(oscillation: StatOscillation) -> void:
	_oscillations.append(oscillation)


func process_frame(delta: float) -> void:
	for oscillation in _oscillations:
		oscillation.advance(delta)


func get_percentage_offset(key: StringName) -> float:
	var total_offset := 0.0
	for modifier in _percentage_modifiers:
		if modifier.stat_key == key:
			total_offset += _resolve_value(modifier)
	for modifier in _until_miss_percentage_modifiers:
		if modifier.stat_key == key:
			total_offset += _resolve_value(modifier)
	return total_offset


func _sum_percentage_multiplier(
	key: StringName, sources: Array[StatModifier], until_miss_sources: Array[StatModifier] = []
) -> float:
	var total_offset := 0.0
	for modifier in sources:
		if modifier.stat_key == key:
			total_offset += _resolve_value(modifier)
	for modifier in until_miss_sources:
		if modifier.stat_key == key:
			total_offset += _resolve_value(modifier)
	return 1.0 + total_offset


func _resolve_value(modifier: StatModifier) -> float:
	if modifier.range_stat_key:
		return modifier.value * get_permanent_stat(modifier.range_stat_key)
	return modifier.value


func _exclude_source(modifier: StatModifier, source_key: String) -> bool:
	return modifier.source_key != source_key


func set_state(state: StringName, source_key: String) -> void:
	_active_states[state] = source_key


func clear_state(state: StringName) -> void:
	_active_states.erase(state)


func is_state_active(state: StringName) -> bool:
	return _active_states.has(state)
