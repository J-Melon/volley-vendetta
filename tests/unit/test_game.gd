extends GutTest

var _game: Node2D
var _ball_dbl
var _paddle_dbl
var _hud: Node


func before_each() -> void:
	_ball_dbl = double("res://scripts/ball.gd").new()
	_paddle_dbl = double("res://scripts/paddle.gd").new()
	_hud = load("res://tests/stubs/hud_stub.gd").new()

	_game = load("res://scripts/game.gd").new()
	_game.ball = _ball_dbl
	_game.paddle = _paddle_dbl
	_game.hud = _hud
	add_child_autofree(_game)


# --- paddle_hit signal ---


func test_ball_speed_increases_on_paddle_hit() -> void:
	_paddle_dbl.paddle_hit.emit()
	assert_called(_ball_dbl, "increase_speed")


func test_hud_updates_on_paddle_hit() -> void:
	_paddle_dbl.paddle_hit.emit()
	assert_eq(_hud.last_count, 1)


func test_hud_increments_each_paddle_hit() -> void:
	_paddle_dbl.paddle_hit.emit()
	_paddle_dbl.paddle_hit.emit()
	assert_eq(_hud.last_count, 2)


# --- missed signal ---


func test_ball_speed_resets_on_miss() -> void:
	_ball_dbl.missed.emit()
	assert_called(_ball_dbl, "reset_speed")


func test_paddle_streak_resets_on_miss() -> void:
	_ball_dbl.missed.emit()
	assert_called(_paddle_dbl, "reset_streak")


func test_hud_resets_to_zero_on_miss() -> void:
	_paddle_dbl.paddle_hit.emit()
	_paddle_dbl.paddle_hit.emit()
	_ball_dbl.missed.emit()
	assert_eq(_hud.last_count, 0)
