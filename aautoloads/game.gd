extends Node

var world: Overworld = null
var battleground: BattleGround = null

var player: Array[Character]

func _ready() -> void:
	var worlds := get_tree().get_nodes_in_group("world")
	if len(worlds) > 0:
		world = worlds[0]

	var battlegrounds := get_tree().get_nodes_in_group("battleground")
	if len(battlegrounds) > 0:
		battleground = battlegrounds[0]

	var char := Character.new()
	player = [ char ]

func enter_battle(enemies: Array[Character]) -> void:
	if not battleground:
		return

	world.process_mode = Node.PROCESS_MODE_DISABLED
	world.camera.enabled = false
	battleground.startup_battle(player, enemies)

func enter_overworld() -> void:
	world.process_mode = Node.PROCESS_MODE_INHERIT
	world.camera.enabled = true
