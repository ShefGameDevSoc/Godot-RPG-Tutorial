extends Node

var world: Overworld = null
var battleground: BattleGround = null

func _ready() -> void:
	var worlds := get_tree().get_nodes_in_group("world")
	if len(worlds) > 0:
		world = worlds[0]

	var battlegrounds := get_tree().get_nodes_in_group("battleground")
	if len(battlegrounds) > 0:
		battleground = battlegrounds[0]

func enter_battle(players: Array[Character], enemies: Array[Character]) -> void:
	if not battleground:
		return

	world.process_mode = Node.PROCESS_MODE_DISABLED
	battleground.startup_battle(players, enemies)
	switch_to_battleground_cameras()

func enter_overworld() -> void:
	world.process_mode = Node.PROCESS_MODE_INHERIT
	world.enter()
	switch_to_overworld_cameras()

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
