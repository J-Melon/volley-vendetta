extends GutTest

const HitTracker := preload("res://scripts/hit_tracker.gd")

# Verifies friendship point tracking — FP is the currency of the game

var _game: Node2D
var _ball: RigidBody2D
var _paddle: CharacterBody2D
var _last_friendship_total := -1


func before_each() -> void:
	_ball = load("res://scripts/ball.gd").new()

	_paddle = load("res://scripts/paddle.gd").new()
	var sound := AudioStreamPlayer.new()
	_paddle.add_child(sound)
	_paddle.hit_sound = sound

	_game = load("res://scripts/game.gd").new()
	_game.ball = _ball
	_game.paddle = _paddle
	add_child_autofree(_ball)
	add_child_autofree(_paddle)
	add_child_autofree(_game)
	_game.friendship_total_changed.connect(func(total): _last_friendship_total = total)
	_ball.gravity_scale = 0.0
	_ball.linear_velocity = Vector2(GameRules.BALL_SPEED_MIN, 0.0)


func _hit() -> void:
	_paddle.on_ball_hit()
	_paddle.tracker.process(HitTracker.COOLDOWN)


func test_fp_increments_on_each_hit() -> void:
	_hit()
	assert_eq(_last_friendship_total, 1)
	_hit()
	assert_eq(_last_friendship_total, 2)
	_hit()
	assert_eq(_last_friendship_total, 3)


func test_fp_persists_after_miss() -> void:
	_hit()
	_hit()
	_hit()
	_ball.missed.emit()
	assert_eq(_last_friendship_total, 3)


func test_fp_accumulates_across_multiple_rallies() -> void:
	_hit()
	_hit()
	_ball.missed.emit()
	_paddle.tracker.process(HitTracker.COOLDOWN)
	_hit()
	_hit()
	_hit()
	_ball.missed.emit()
	assert_eq(_last_friendship_total, 5)
