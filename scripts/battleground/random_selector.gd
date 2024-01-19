class_name RandomSelector
extends Node

@onready var selector := $Selector

@onready var _think_timer := $ThinkTimer

var _action: Action
var _target: BGActor

func _on_action_selection_started(me: BGActor, allies: Array[BGActor], opponents: Array[BGActor]) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var idx: int = rng.randi() % len(me.character.get_all_actions())
	_action = me.character.get_all_actions()[idx]

	match _action.targets:
		Action.Target.EVERYONE:
			# If it's a healing action choose allies otherwise choose opponents
			var possibles := allies + [ me ] if _action.type == Action.Type.HEALING else opponents
			idx = rng.randi() % len(possibles)
			_target = possibles[idx]
		Action.Target.ALLIES:
			idx = rng.randi() % len(allies)
			_target = allies[idx]
		Action.Target.OPPONENTS:
			idx = rng.randi() % len(opponents)
			_target = opponents[idx]
		Action.Target.SELF:
			_target = me
		Action.Target.NOT_SELF:
			# If it's a healing action choose allies otherwise choose opponents
			var possibles := allies if _action.type == Action.Type.HEALING else opponents
			idx = rng.randi() % len(possibles)
			_target = possibles[idx]
	
	_think_timer.start()

func _on_think_timer_timeout() -> void:
	selector.action_selected.emit(_target, _action)
