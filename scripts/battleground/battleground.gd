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
const ps_random_selector := preload("res://battlegrounds/RandomSelector.tscn")

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
	teams = []
	var team := Team.new()
	for char in players:
		var actor: BGActor = ps_rpg_actor.instantiate()
		team.actors.append(actor)
		actor.position.x = -200
		_actors.add_child(actor)

		var hud: BattleHUD = ps_selection_hud.instantiate()
		hud.populate_action_list(char)
		_huds.add_child(hud)
		actor.selector = hud.selector

		actor.character = char
		actor.update_ui()

	teams.append(team)
	team = Team.new()

	for char in enemies:
		var actor: BGActor = ps_rpg_actor.instantiate()
		team.actors.append(actor)
		actor.position.x = 200
		_actors.add_child(actor)

		var rs: RandomSelector = ps_random_selector.instantiate()
		_huds.add_child(rs)
		actor.selector = rs.selector

		actor.character = char
		actor.update_ui()

	teams.append(team)
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
	for loser in losers:
		for actor in loser.actors:
			if actor.is_in_group("player"):
				get_tree().quit()

	_clean_up_battleground()

func _execute_turn() -> void:
	in_turn = true
	var all_actors := _actors.get_children()

	# Here is where you would sort by speed

	for rpga: BGActor in all_actors:
		print("%s 's turn" % rpga.character.name)
		var my_team: Team = null
		for team: Team in teams:
			if rpga in team.actors:
				my_team = team
				break

		if my_team == null:
			print("Unknown BG Actor %s" % rpga.name)
			_actors.remove_child(rpga)
			continue

		var allies: Array[BGActor] = []
		var opponents: Array[BGActor] = []
		for team: Team in teams:
			if team == my_team:
				allies = allies + team.actors
			else:
				opponents = opponents + team.actors

		var params := await rpga.make_choice(allies, opponents)
		if len(params) == 0:
			continue
		var target: BGActor = params[0]
		var action: Action = params[1]
		_apply_action(rpga, target, action)

	in_turn = false

func _apply_action(user: BGActor, target: BGActor, action: Action) -> void:
	if not action.cannot_miss and float(action.accuracy) < randf() * 100.0:
		print("%s's attack missed!" % user.character.name)
		return

	match action.type:
		Action.Type.ATTACK:
			# Calculation derived from Pokemon's damage calculations
			# https://bulbapedia.bulbagarden.net/wiki/Damage
			var damage := int(action.power * user.character.attack
						  / target.character.defense * (1.0 - randf() * 0.2))
			print("Dealing %d damage to %s" % [ damage, target.character.name ])
			target.character.health = max(0, target.character.health - damage)

		Action.Type.HEALING:
			var heal_points_from_ratio := int(target.character.max_health * action.heal_ratio)
			var to_heal: int = action.health_points if action.health_points else heal_points_from_ratio
			print("Healing %s by %s" % [ target.character.name, to_heal ])
			target.character.health = min(target.character.max_health,
										  target.character.health + to_heal)

	target.update_ui()

	if target.character.health <= 0:
		print("%s has died" % target.name)
		_check_for_battle_end()

func _check_for_battle_end() -> void:
	var is_dead := func (actor: BGActor) -> bool:
		return actor.character.health <= 0

	var not_all_dead: Array[Team] = []
	var all_dead: Array[Team] = []
	for team: Team in teams:
		if team.actors.all(is_dead):
			all_dead.append(team)
		else:
			not_all_dead.append(team)

	if len(not_all_dead) > 1:
		return

	_end_battle(not_all_dead[0], all_dead)

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
