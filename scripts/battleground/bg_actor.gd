class_name BGActor
extends CharacterBody2D
## Actor for the BattleGround
##
## This script does not contain specifics about how the actor will decide who and how
## to attack

## A signal to be used by [BattleHUD] to know what the target of an action will be
signal body_selected(rpg_actor)

var character: Character

## An unique ID for multiplayer battles, so this actor can be the same for both the client and server
var multiplayer_id: int

@onready var _name: Label = $UI/Name
@onready var _health_bar: ProgressBar = $UI/HealthBar

var selector: SelectorInterface = null

## Triggers this actor's selection process
##
## This function is asynchronus
func make_choice(in_allies: Array[BGActor], in_opponents: Array[BGActor]) -> Array:
	# Filter out untargetable actors
	var is_targetable := func (actor: BGActor):
		return actor != self

	var allies := in_allies.filter(is_targetable)
	var opponents := in_opponents.filter(is_targetable)

	selector.action_selection_started.emit(self, allies, opponents)
	var res: Array[Variant] = await selector.action_selected
	return [] if res == null else res

## Updates the UI for this actor
func update_ui() -> void:
	_health_bar.value = float(character.health) / float(character.max_health)
	_name.text = character.name

func _on_input_event(viewport, event, shape_idx) -> void:
	var mbEvent := event as InputEventMouseButton
	if mbEvent and mbEvent.pressed:
		body_selected.emit(self)
