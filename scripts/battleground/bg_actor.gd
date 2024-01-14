class_name BGActor
extends CharacterBody2D

signal action_selection_started(me, allies, oppnents)

signal body_selected(rpg_actor)

var character: Character

@export var library: ActionLibrary

@onready var _health_bar: ProgressBar = $HealthBar

var selector = null

func make_choice(in_allies: Array[BGActor], in_opponents: Array[BGActor]) -> Array:
	# Filter out untargetable actors
	var is_targetable := func (actor: BGActor):
		return actor != self

	var allies := in_allies.filter(is_targetable)
	var opponents := in_opponents.filter(is_targetable)

	action_selection_started.emit(self, allies, opponents)
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
