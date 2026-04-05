class_name ShopItem
extends Node2D

@export var icon_sprite: Sprite2D
@export var hit_area: Area2D
@export var tooltip: ShopTooltip

var item_definition: ItemDefinition
var _hovered := false


func setup(definition: ItemDefinition) -> void:
	item_definition = definition


func _ready() -> void:
	_build_visuals()
	ItemManager.friendship_point_balance_changed.connect(_on_friendship_point_balance_changed)
	ItemManager.item_level_changed.connect(_on_item_level_changed)
	hit_area.mouse_entered.connect(_on_hover_enter)
	hit_area.mouse_exited.connect(_on_hover_exit)


func _process(_delta: float) -> void:
	if _hovered:
		tooltip.follow_mouse(get_global_mouse_position())


func _build_visuals() -> void:
	if item_definition == null:
		return
	if item_definition.icon != null:
		icon_sprite.texture = item_definition.icon
	tooltip.show_item(item_definition.display_name, _get_cost_text())
	tooltip.hide_tooltip()


## Replace with friend reaction on art pass
func _on_hover_enter() -> void:
	_hovered = true
	tooltip.visible = true


func _on_hover_exit() -> void:
	_hovered = false
	tooltip.hide_tooltip()


func _get_cost_text() -> String:
	var current_level: int = ItemManager.get_level(item_definition.key)
	if current_level >= item_definition.max_level:
		return "Taken"
	return "%d FP" % ItemManager.calculate_cost(item_definition.key)


func _update_cost() -> void:
	tooltip.update_cost(_get_cost_text())


func _on_friendship_point_balance_changed(_balance: int) -> void:
	_update_cost()


func _on_item_level_changed(item_key: String) -> void:
	if item_key == item_definition.key:
		_update_cost()
