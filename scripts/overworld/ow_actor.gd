class_name OWActor
extends Node2D

enum MoveDirection { NONE, UP, DOWN, LEFT, RIGHT }

@export var is_blocking := true

var move_direction := MoveDirection.NONE

# Called when the node enters the scene tree for the first time.
func _ready():
	if Game.world != null:
		Game.world.add_actor(self)

func _process(delta: float) -> void:
	if move_direction != MoveDirection.NONE:
		return

	if Input.is_action_pressed("up"):
		move_direction = MoveDirection.UP
	elif Input.is_action_pressed("down"):
		move_direction = MoveDirection.DOWN
	elif Input.is_action_pressed("left"):
		move_direction = MoveDirection.LEFT
	elif Input.is_action_pressed("right"):
		move_direction = MoveDirection.RIGHT
