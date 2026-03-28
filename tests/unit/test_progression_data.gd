extends GutTest

# Tests for ProgressionData — save/load stubs for now, will cover real persistence in SH-31.

var _data: ProgressionData


func before_each() -> void:
	_data = ProgressionData.new()


func test_save_returns_true() -> void:
	assert_true(_data.save())


func test_load_returns_true() -> void:
	assert_true(_data.load())
