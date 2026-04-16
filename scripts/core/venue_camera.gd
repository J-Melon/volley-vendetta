class_name VenueCamera
extends Camera2D

# todo: sh-106 clamp to venue bounds once shop and workshop placeholders exist.

@export var pan_speed: float = 800.0


func _process(delta: float) -> void:
	var direction: float = Input.get_axis(&"camera_left", &"camera_right")
	if direction != 0.0:
		position.x += direction * pan_speed * delta
