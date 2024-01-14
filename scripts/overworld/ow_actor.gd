class_name OWActor
extends Node2D

signal bumped_into_unwalkable(direction)
signal other_entered_my_cell(other_actor)

enum MoveDirection { NONE, UP, DOWN, LEFT, RIGHT }

@export var is_blocking := true
@export_range(0.2, 10) var move_speed_multiplier := 1.0

var move_direction := MoveDirection.NONE

# Called when the node enters the scene tree for the first time.
func _ready():
	if Game.world != null:
		Game.world.add_actor(self)
