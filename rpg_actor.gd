class_name RPGActor
extends CharacterBody2D

signal action_selection_started(me, targetable_actors)

signal body_selected(rpg_actor)

var character: Character

@export var library: ActionLibrary

@onready var _health_bar: ProgressBar = $HealthBar

var selector = null

func make_choice(all_actors: Array[RPGActor]) -> Array:
	# Filter out untargetable actors
	var actors: Array[RPGActor] = []
	for rpga in all_actors:
		if rpga == self:
			continue

		actors.append(rpga)

	action_selection_started.emit(self, actors)
	if selector == null:
		print("%s's selector is unassigned" % name)
		return []
	# Array
	var res = await selector.action_selected
	return [] if res == null else res

func update_health() -> void:
	_health_bar.value = float(character.health) / float(character.max_health)

func _on_input_event(viewport, event, shape_idx) -> void:
	var mbEvent := event as InputEventMouseButton
	if mbEvent and mbEvent.pressed:
		body_selected.emit(self)
