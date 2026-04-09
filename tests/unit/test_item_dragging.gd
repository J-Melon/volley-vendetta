extends GutTest

const ItemDraggingScene: PackedScene = preload("res://scenes/items/item_dragging.tscn")
const RealItem: ItemDefinition = preload("res://resources/items/grip_tape.tres")


class TestShowItem:
	extends GutTest

	var _dragging: ItemDragging

	func before_each() -> void:
		_dragging = ItemDraggingScene.instantiate()
		add_child_autofree(_dragging)

	func test_show_item_instantiates_art_into_viewport() -> void:
		_dragging.show_item(RealItem)
		assert_eq(_dragging.art_viewport.get_child_count(), 1)

	func test_show_item_matches_source_art_size() -> void:
		_dragging.show_item(RealItem)
		var art: ItemArt = _dragging.art_viewport.get_child(0)
		assert_eq(_dragging.custom_minimum_size, art.bounding_rect.size)

	func test_show_item_does_nothing_when_definition_is_null() -> void:
		_dragging.show_item(null)
		assert_eq(_dragging.art_viewport.get_child_count(), 0)


class TestOpacity:
	extends GutTest

	func test_root_renders_opaque_for_seamless_lift() -> void:
		var dragging: ItemDragging = ItemDraggingScene.instantiate()
		add_child_autofree(dragging)
		assert_almost_eq(dragging.modulate.a, 1.0, 0.01)
