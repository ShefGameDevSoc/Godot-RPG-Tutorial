extends Node
## Autoload for the lobby system
##
## While also providing general lobby system functionality, it also provides many
## RPC functions for the battle system
##
## This lobby system only takes one client and treats the server as player.
## Therefore it is not to be used as a dedicated server as is

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

#// We define the Port Number to use
#// Port numbers define channels for computers to communicate with each other
#// Port numbers range from 0 - 65'536 although many of them are resolved
#// https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const PORT = 4433
const MAX_CONNECTIONS = 2

var players := {}
var player_info: Dictionary

func _ready() -> void:
	#// multiplayer is a field on every Node that is used to connect to Godot's multplayer system
	#// Here we are wiring up some signals
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

## Creates the multiplayer server
##
## To be used by the host for the lobby
func create_lobby(name: String) -> Error:
	#// Instantiate a multiplayer peer and use it create a server
	var peer := ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error

	#// If there are no errors assign it the multiplayer object
	multiplayer.multiplayer_peer = peer

	var chars := _get_player_characters()
	if chars == []:
		print("No player characters found")
		return ERR_UNAVAILABLE

	player_info = { "name": "[H] " + name, "characters": chars }
	players[get_id()] = player_info
	player_connected.emit(get_id(), player_info)
	return 0

## Attempts to join the lobby at [param address]
##
## If [param address] is set to the empty string it will default to
## localhost
func join_lobby(address: String, name: String) -> Error:
	if not address:
		address = "127.0.0.1"

	#// Create a multiplayer peer, but this use it create a client for the server at the address and port
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

## Disconnects from the server
func cancel_lobby() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer = null

## Disconnects from the server and emits the signal [signal server_disconnected]
func leave_lobby() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer = null
		server_disconnected.emit()

func is_server() -> bool: return multiplayer.multiplayer_peer and multiplayer.is_server()

## Returns the the local peers unique ID
func get_id() -> int: return multiplayer.get_unique_id() if multiplayer.has_multiplayer_peer() else -1

func _on_player_connected(id: int) -> void:
	#// Calls an rpc function for a specific lobby ID
	_register_player.rpc_id(id, player_info)

func _on_player_disconnected(id: int) -> void:
	players.erase(id)
	print("Player %d disconnected" % id)

func _on_connected_ok() -> void:
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail() -> void:
	multiplayer.multiplayer_peer = null

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	Game.battleground.client_end_multiplayer_battle(1, [ 1 ])
	print("Server disconnected")

#// The rpc annotation
#// Attach this to function and you can call it on peers in a multiplayer game
#// We'll talk about this more next
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

## Serialises the [member OWActor.characters] from the [OWActor] in the player group
##
## This is a necessary step to sending the [Character] data across the network
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

## [b]Server[/b] Sends the winner and losers from the battle to client
@rpc("authority", "call_remote")
func send_battle_results(winner: int, losers_: Array) -> void:
	pass

## [b]Server[/b] Tells the client what [BGActor]s to instantiate in its local battleground
## scene
@rpc("authority", "call_local", "reliable")
func instantiate_actor(lobby_id: int, idx_character: int, multiplayer_id: int) -> void:
	pass

## [b]Server[/b] Tells the client to begin selecting their attack and target
@rpc("authority", "call_remote", "reliable")
func peer_select_action(me: int, allies_: Array, opponents_: Array) -> void:
	pass

## [b]Client[/b] Sends the target index and [Action] resource path to the server
@rpc("any_peer", "call_remote", "reliable")
func client_action_selected(target: int, action: String) -> void:
	pass

## [b]Server[/b] Tells the client the new state of the battleground for it to update to
@rpc("authority", "call_remote", "reliable")
func update_battle_state(state: Dictionary) -> void:
	pass

## [b]Server[/b] Tells all peers (ie. the server player and the client player) to go to the battleground
@rpc("any_peer", "call_local", "reliable")
func show_battleground() -> void:
	pass
