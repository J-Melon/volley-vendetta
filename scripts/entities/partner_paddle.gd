class_name PartnerPaddle
extends Paddle

@export var controller: PartnerAIController


func _ready() -> void:
	_lane_x = position.x
	_paddle_speed = GameRules.base_stats[&"paddle_speed"]

	if collision != null:
		_collision_shape = RectangleShape2D.new()
		_collision_shape.size = collision.shape.size
		collision.shape = _collision_shape

	if sprite != null:
		_sprite_natural_height = sprite.get_rect().size.y

	_apply_base_size()


func _apply_base_size() -> void:
	if _collision_shape == null:
		return

	var arena_height: float = GameRules.base_stats[&"arena_height"]
	var paddle_size_min: float = GameRules.base_stats[&"paddle_size_min"]
	var new_size: float = clampf(
		GameRules.base_stats[&"paddle_size"], paddle_size_min, arena_height
	)

	_collision_shape.size.y = new_size

	if sprite != null and _sprite_natural_height > 0.0:
		sprite.scale.y = new_size / _sprite_natural_height


func set_ball(value: RigidBody2D) -> void:
	controller.enable_with_ball(value)
