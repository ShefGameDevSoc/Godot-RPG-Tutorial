class_name BattleGround
extends Node2D
## Executes the turn based combat of the battles
##
## Sets up [BGActor]s to represent the [Character]s partaking in the battle
## Handles the turn based combat using signals. This script is also set up to
## handle multiplayer

const ps_rpg_actor := preload("res://actors/battleground/BGActor.tscn")

enum BattleType { AI, ONLINE }

@onready var _actors := $Actors
@onready var _huds := $HUDs

var in_turn: bool = false

## Represents a side of the battle
class Team:
	var actors: Array[BGActor]

var teams: Array[Team] = []
var actors_by_multiplayer_id: Dictionary

var multiplayer_me: PeerBattler
var multiplayer_opponent: PeerBattler

## Starts a local battle, most commonly between the player and AI
##
## Populates the battleground with [BGActor]s then enables the node this script is
## attaached to
func startup_battle(players: Array[Character], enemies: Array[Character]) -> void:
	show()

func _process(delta: float) -> void:
	if not in_turn:
		_execute_turn()

func _clean_up_battleground() -> void:
	hide()
	teams = []
	for c: Node in _actors.get_children() + _huds.get_children():
		c.queue_free()
	Game.enter_overworld()

func _end_battle(winner: Team, losers: Array[Team]) -> void:
	hide()

func _execute_turn() -> void:
	in_turn = true

func _apply_action(user: BGActor, target: BGActor, action: Action) -> void:
	pass
