class_name ItemDragging
extends Control

@export var art_viewport: SubViewport
@export var art_viewport_container: SubViewportContainer


func show_item(definition: ItemDefinition) -> void:
	if definition == null or definition.art == null:
		return
	var art_instance: ItemArt = definition.art.instantiate()
	art_viewport.add_child(art_instance)
	var bounds: Rect2 = art_instance.bounding_rect
	if bounds.size == Vector2.ZERO:
		return
	art_instance.position -= bounds.position
	art_viewport.size = Vector2i(bounds.size.ceil())
	art_viewport_container.custom_minimum_size = bounds.size
	custom_minimum_size = bounds.size
