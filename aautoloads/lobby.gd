extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 4433
const MAX_CONNECTIONS = 2

var players := {}
var player_info: Dictionary

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_lobby(name: String) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error

	multiplayer.multiplayer_peer = peer

	var chars := _get_player_characters()
	if chars == []:
		print("No player characters found")
		return ERR_UNAVAILABLE

	player_info = { "name": "[H] " + name, "characters": chars }
	players[get_id()] = player_info
	player_connected.emit(get_id(), player_info)
	return 0

func join_lobby(address: String, name: String) -> Error:
	if address:
		address = "127.0.0.1"

	var peer := ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(address, PORT)
	if error:
		return error

	var chars := _get_player_characters()
	if chars == []:
		print("No player characters found")
		return ERR_UNAVAILABLE

	player_info = { "name": name, "characters": chars }
	multiplayer.multiplayer_peer = peer
	return 0

func leave_lobby() -> void:
	server_disconnected.emit()

func is_server() -> bool: return multiplayer.multiplayer_peer and multiplayer.is_server()

func get_id() -> int: return multiplayer.get_unique_id()

func _on_player_connected(id: int) -> void:
	_register_player.rpc_id(id, player_info)

func _on_player_disconnected(id: int) -> void:
	players.erase(id)

func _on_connected_ok() -> void:
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail() -> void:
	multiplayer.multiplayer_peer = null

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()

@rpc("any_peer", "reliable")
func _register_player(peer_info: Dictionary) -> void:
	var id: int = multiplayer.get_remote_sender_id()
	players[id] = peer_info

	var my_chars: Array[Character] = []
	for dict_char in player_info.characters:
		var c := Character.from_dict(dict_char)
		c.name = player_info.name + " " + c.name
		my_chars.append(c)
	var me := PeerBattler.new(get_id(), player_info.name, my_chars)

	var opponent_chars: Array[Character] = []
	for dict_char in peer_info.characters:
		var c := Character.from_dict(dict_char)
		c.name = peer_info.name + " " + c.name
		opponent_chars.append(c)
	var opponent := PeerBattler.new(id, peer_info.name, opponent_chars)

	Game.enter_multiplayer_battle.call_deferred(me, opponent)

func _get_player_characters() -> Array[Dictionary]:
	var in_group: Array[Node] = get_tree().get_nodes_in_group("player")
	if len(in_group) == 0:
		return []

	var actor := in_group[0] as OWActor
	if not actor:
		return []

	var chars: Array[Dictionary] = []
	for c in actor.characters:
		chars.append(c.to_dict())

	return chars

#########
# BATTLEGROUND FUNCTIONS
#########

var current_peer_selector: PeerSelector

@rpc("authority", "call_remote")
func send_battle_results(winner: int, losers_: Array) -> void:
	var losers: Array[int] = []
	losers.assign(losers_)
	Game.battleground.end_multiplayer_battle(winner, losers)

@rpc("authority", "call_local", "reliable")
func instantiate_actor(lobby_id: int, idx_character: int, multiplayer_id: int) -> void:
	Game.battleground.multiplayer_instantiate(lobby_id, idx_character, multiplayer_id)

@rpc("authority", "call_remote", "reliable")
func peer_select_action(me: int, allies_: Array, opponents_: Array) -> void:
	var allies: Array[int]
	var opponents: Array[int]
	allies.assign(allies_)
	opponents.assign(opponents_)
	Game.battleground.client_selection(multiplayer.get_remote_sender_id(),
									   me, allies, opponents)

@rpc("any_peer", "call_remote", "reliable")
func client_action_selected(target: int, action: String) -> void:
	if current_peer_selector:
		current_peer_selector.peer_action_selected(target, action)
		current_peer_selector = null

@rpc("authority", "call_remote", "reliable")
func update_battle_state(state: Dictionary) -> void:
	Game.battleground.update_battle_state(state)

@rpc("any_peer", "call_local", "reliable")
func show_battleground() -> void:
	Game.battleground.show()
