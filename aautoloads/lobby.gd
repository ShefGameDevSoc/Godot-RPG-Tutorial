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

	player_info = { "name": name, "characters": chars }
	players[1] = player_info
	player_connected.emit(1, player_info)
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

func is_server() -> bool: return multiplayer.is_server()

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
		my_chars.append(Character.from_dict(dict_char))
	var me := PeerBattler.new(1, player_info.name, my_chars)

	var opponent_chars: Array[Character] = []
	for dict_char in peer_info.characters:
		opponent_chars.append(Character.from_dict(dict_char))
	var opponent := PeerBattler.new(multiplayer.get_remote_sender_id(),
									peer_info.name, opponent_chars)

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
