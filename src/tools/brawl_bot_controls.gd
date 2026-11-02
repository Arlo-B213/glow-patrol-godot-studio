extends Control
## Stand-in for the Alley Brawl touch controls, used by brawl_bot_playtest.gd: reports the bot's
## chosen movement, never blocks, and carries the fields the HUD reads from the real controls.

signal punch_pressed

var move := Vector2.ZERO
var active := true
var guard_ratio := 1.0
var guard_broken := false


func read_move() -> Vector2:
	return move


func read_axis() -> float:
	return move.x


func poll_block() -> bool:
	return false
