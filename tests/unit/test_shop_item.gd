extends GutTest


class TestShopItemDisplay:
	extends GutTest

	const ShopItemScene: PackedScene = preload("res://scenes/shop_item.tscn")

	var _item: ShopItem
	var _definition: ItemDefinition

	func before_each() -> void:
		_definition = ItemManager.items[0]
		_item = ShopItemScene.instantiate()
		_item.setup(_definition)
		add_child_autofree(_item)

	func test_displays_item_name() -> void:
		assert_eq(_item.tooltip.name_label.text, _definition.display_name)

	func test_displays_cost_or_taken() -> void:
		var current_level: int = ItemManager.get_level(_definition.key)
		if current_level >= _definition.max_level:
			assert_eq(_item.tooltip.cost_label.text, "Taken")
		else:
			var expected_cost: int = ItemManager.calculate_cost(_definition.key)
			assert_eq(_item.tooltip.cost_label.text, "%d FP" % expected_cost)

	func test_tooltip_hidden_by_default() -> void:
		assert_false(_item.tooltip.visible)


class TestShopPanelLayout:
	extends GutTest

	const ShopScene: PackedScene = preload("res://scenes/shop.tscn")

	func test_spawns_visible_items() -> void:
		var panel: ShopPanel = ShopScene.instantiate()
		add_child_autofree(panel)
		var container: Node2D = panel.get_node("ItemContainer")
		assert_gt(container.get_child_count(), 0)

	func test_friendship_label_shows_current_balance() -> void:
		var panel: ShopPanel = ShopScene.instantiate()
		add_child_autofree(panel)
		var expected_balance: int = ItemManager.get_friendship_point_balance()
		assert_eq(panel.friendship_label.text, "Friendship: %d" % expected_balance)
