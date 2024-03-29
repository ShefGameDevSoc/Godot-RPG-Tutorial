extends Node
## Autoload for the game state
##
## Contains functions for switching between the two major states: Overworld and BattleGround
## Fins the relevant nodes using groups

signal entered_overworld
signal entered_battle

var world: Overworld = null
var battleground: BattleGround = null

var in_battle := false

func _ready() -> void:
	var worlds := get_tree().get_nodes_in_group("world")
	if len(worlds) > 0:
		world = worlds[0]

	var battlegrounds := get_tree().get_nodes_in_group("battleground")
	if len(battlegrounds) > 0:
		battleground = battlegrounds[0]

	Lobby.server_disconnected.connect(self.enter_overworld)

## Switches the active state to the battleground
## Takes in one array of characters for the two soides of the battle, the player and the enemies
func enter_battle(players: Array[Character], enemies: Array[Character]) -> void:
	if not battleground:
		return

	in_battle = true
	world.process_mode = Node.PROCESS_MODE_DISABLED
	battleground.startup_battle(players, enemies)
	switch_to_battleground_cameras()
	entered_battle.emit()

## Switches the active state to the battleground, in preparation for a multiplayer battle
## Takes in [PeerBattler] objects for both sides
func enter_multiplayer_battle(me: PeerBattler, opponent: PeerBattler) -> void:
	if not battleground:
		return

	in_battle = true
	world.process_mode = Node.PROCESS_MODE_DISABLED
	switch_to_battleground_cameras()
	battleground.startup_multiplayer_battle(me, opponent)
	entered_battle.emit()

## Switches the active scene to overworld
func enter_overworld() -> void:
	in_battle = false
	world.process_mode = Node.PROCESS_MODE_INHERIT
	world.enter()
	switch_to_overworld_cameras()
	entered_overworld.emit()

func switch_to_overworld_cameras() -> void:
	for cam: Camera2D in get_tree().get_nodes_in_group("cam_overworld"):
		cam.enabled = true
	for cam: Camera2D in get_tree().get_nodes_in_group("cam_battleground"):
		cam.enabled = false

func switch_to_battleground_cameras() -> void:
	for cam: Camera2D in get_tree().get_nodes_in_group("cam_overworld"):
		cam.enabled = false
	for cam: Camera2D in get_tree().get_nodes_in_group("cam_battleground"):
		cam.enabled = true
