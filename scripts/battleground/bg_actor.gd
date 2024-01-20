class_name BGActor
extends CharacterBody2D

signal action_selection_started(me, allies, oppnents)

signal body_selected(rpg_actor)

var character: Character

@onready var _name: Label = $UI/Name
@onready var _health_bar: ProgressBar = $UI/HealthBar

var selector: SelectorInterface = null

func make_choice(in_allies: Array[BGActor], in_opponents: Array[BGActor]) -> Array:
	# Filter out untargetable actors
	var is_targetable := func (actor: BGActor):
		return actor != self

	var allies := in_allies.filter(is_targetable)
	var opponents := in_opponents.filter(is_targetable)

	selector.action_selection_started.emit(self, allies, opponents)
	#action_selection_started.emit(self, allies, opponents)
	# Array
	var res = await selector.action_selected
	return [] if res == null else res

func update_character_ui() -> void:
	update_health()
	_name.text = character.name

func update_health() -> void:
	_health_bar.value = float(character.health) / float(character.max_health)

func _on_input_event(viewport, event, shape_idx) -> void:
	var mbEvent := event as InputEventMouseButton
	if mbEvent and mbEvent.pressed:
		body_selected.emit(self)
