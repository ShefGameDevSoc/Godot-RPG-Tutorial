class_name OWActor
extends Node2D
## An Actor for the Overworld

#// Declare a signal, putting the parameters it takes in parenthesis
#// Note that signal parameters cannot have type declarations
signal bumped_into_unwalkable(direction)
signal other_entered_my_cell(other_actor)
signal actor_died()

enum MoveDirection { NONE, UP, DOWN, LEFT, RIGHT }

@export var is_blocking := true
@export_range(0.2, 10) var move_speed_multiplier := 1.0

var characters: Array[Character]
var move_direction := MoveDirection.NONE

## Checks if the actor is alive, if not emits [signal OWActor.actor_died]
##
## Called upon re-entry into an [Overworld]
func check_if_alive() -> void:
	for c in characters:
		if c.health > 0:
			return

	#// Emitting a signal, everyone connected to this signal will get called
	actor_died.emit()

func _ready():
	if Game.world != null:
		Game.world.add_actor(self)
