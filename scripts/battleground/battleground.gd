#// This is the name of the class
class_name BattleGround
#// This class inherits from Node2D
extends Node2D
#// Comments beginning with two hashes are documentation comments
## Executes the turn based combat of the battles
##
## Sets up [BGActor]s to represent the [Character]s partaking in the battle
## Handles the turn based combat using signals. This script is also set up to
## handle multiplayer

#// The 'const' keyword defines a constant, a variable that cannot be changed later
#// The preload function loads an asset from the file system
const ps_rpg_actor := preload("res://actors/battleground/BGActor.tscn")
const ps_selection_hud := preload("res://battlegrounds/ui/BattleHUD.tscn")

enum BattleType { AI, ONLINE }

#// The @onready annotation says that this variable will be set just before the _ready() function
#// is called
#// $ is used to declare a node path, e.g. $Actors points to the child node called 'Actors'
@onready var _actors := $Actors
@onready var _huds := $HUDs

#// Variables are declared with the 'var' keyword
#// When static typing, after the variable name insert a colon (:) followed by the type name
#// As you can see above with _huds, you can also omit the type name, keeping the colon followed by
#// equals (=)
#// If you're not static typing, you can just drop both
var in_turn: bool = false

#// This is an inner class, note the colon (:) after the class name
## Represents a side of the battle
class Team:
	var actors: Array[BGActor]

#// Declare an array of a specific type
#// If the array will mix variables of different types you can drop the '[Team]' part
#// Note that you can have a typed array of arrays (e.g. Array[Array[int]])
#// This is what initialy motivated the creation of the Team class
var teams: Array[Team] = []
var actors_by_multiplayer_id: Dictionary

var multiplayer_me: PeerBattler
var multiplayer_opponent: PeerBattler

## Starts a local battle, most commonly between the player and AI
##
## Populates the battleground with [BGActor]s then enables the node this script is
## attaached to
#// A function declaration, starting with the 'func' keyword, then the function name and
#// the parameter list in parentheses ()
#// If you're not you can get rid of the colon and type declaration (e.g. : Array[Character])
#// and the triling return type (-> void)
#// Note that the ending colon (:) is mandatory
func startup_battle(players: Array[Character], enemies: Array[Character]) -> void:
	#// A function call
	show()

#// A system function, this one is called every frame
#// It is a sibling _ready() that is called when the node first enters a scene
#// In Godot, the delta time is passed into the _process function as a parameter
func _process(delta: float) -> void:
	#// The if state is identical to Python
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

#######################
## MULTIPLAYER STUFF ##
#######################

## Starts a multiplayer battle
##
## Populates the battleground with [BGActor]s then enables the node this script is
## attaached to
## It sends RPCs throughout the lobby to instantiate these actors in order, so that every
## actor has the same ID on every peer
func startup_multiplayer_battle(me: PeerBattler, opponent: PeerBattler) -> void:
	pass

## Instantiates a [BGActor] for use in multiplayer battles
##
## It selectively instantiates an appropriate selector
## If the [Character] belongs to this peer. instantiate a [BattleHUD]
## Otherwise if this peer is the server, instatiate a [ClientSelector]
func multiplayer_instantiate(lobby_id: int, idx_character: int, multiplayer_id: int) -> void:
	pass

## [b]Client[/b] Triggers the client's selection process and returns the results back to the server
func client_selection(sender: int, me_: int, allies_: Array[int], opponents_: Array[int]) -> void:
	pass

## [b]Client[/b] Takes the state of the battle and updates the battleground to reflect it
##
## As of now that only involves the health bars
func update_battle_state(state: Dictionary) -> void:
	pass

## [b]Client[/b] Ends the multiplayer battle on the client
##
## Takes indexes for the teams to denote who won and who lost
func client_end_multiplayer_battle(winner_id: int, losers_ids: Array[int]) -> void:
	pass

func _serialise_battle_state() -> Dictionary:
	return {}

func _end_multiplayer_battle(winner: Team, losers: Array[Team]) -> void:
	pass
