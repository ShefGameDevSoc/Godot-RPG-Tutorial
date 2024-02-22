class_name ClientSelector
extends Node
## A selector that acts as a proy for the client in a multiplayer battle

@onready var selector := $Selector

## The lobby id of the peer this script is acting as a proxy for
var peer_id: int

var all_chars: Array[BGActor]

func _on_action_selection_started(me_: BGActor, allies_: Array[BGActor], opponents_: Array[BGActor]) -> void:
	var me: int = me_.multiplayer_id
	var allies: Array[int] = []
	var opponents: Array[int] = []
	for bga in allies_:
		allies.append(bga.multiplayer_id)
	for bga in opponents_:
		opponents.append(bga.multiplayer_id)

	all_chars.assign([ me_ ] + allies_ + opponents_)
	Lobby.current_peer_selector = self
	Lobby.peer_select_action.rpc_id(peer_id, me, allies, opponents)

## Called by the [Lobby] once the peer has made their decision
func peer_action_selected(target_id: int, action_path: String) -> void:
	var target: BGActor
	for bga in all_chars:
		if bga.multiplayer_id == target_id:
			target = bga
			break

	var action := load(action_path) as Action
	if action == null:
		selector.action_selected.emit()
	else:
		selector.action_selected.emit(target, action)