class_name BattleGround
extends Node2D

const ps_rpg_actor := preload("res://actors/battleground/BGActor.tscn")
const ps_selection_hud := preload("res://battlegrounds/ui/BattleHUD.tscn")
const ps_random_selector := preload("res://battlegrounds/selectors/RandomSelector.tscn")

const ps_peer_selector := preload("res://battlegrounds/selectors/PeerSelector.tscn")

enum BattleType { AI, ONLINE }

@onready var _actors := $Actors
@onready var _huds := $HUDs

var in_turn: bool = false

var in_multiplayer := false

class Team:
	var lobby_id := -1
	var actors: Array[BGActor]

var teams: Array[Team] = []
var actors_by_multiplayer_id: Dictionary

var multiplayer_me: PeerBattler
var multiplayer_opponent: PeerBattler

func startup_battle(players: Array[Character], enemies: Array[Character]) -> void:
	teams = []
	var team := Team.new()
	for char in players:
		var actor: BGActor = ps_rpg_actor.instantiate()
		team.actors.append(actor)
		actor.position.x = -200
		var hud: BattleHUD = ps_selection_hud.instantiate()
		hud.populate_action_list(char)
		_actors.add_child(actor)
		_huds.add_child(hud)

		actor.selector = hud.selector

		actor.character = char
		actor.update_character_ui()

	teams.append(team)
	team = Team.new()

	for char in enemies:
		var actor: BGActor = ps_rpg_actor.instantiate()
		team.actors.append(actor)
		actor.position.x = 200
		var rs: RandomSelector = ps_random_selector.instantiate()
		_actors.add_child(actor)
		_huds.add_child(rs)

		actor.selector = rs.selector

		actor.character = char
		actor.update_character_ui()

	teams.append(team)
	show()
	in_multiplayer = false

func startup_multiplayer_battle(me: PeerBattler, opponent: PeerBattler) -> void:
	teams = [ Team.new(), Team.new() ]
	actors_by_multiplayer_id = {}
	multiplayer_me = me
	multiplayer_opponent = opponent
	in_multiplayer = true
	if not Lobby.is_server():
		return

	var multiplayer_id := 0
	for i in range(len(me.characters)):
		Lobby.instantiate_actor.rpc(me.id, i, multiplayer_id)
		multiplayer_id += 1

	for j in range(len(opponent.characters)):
		Lobby.instantiate_actor.rpc(opponent.id, j, multiplayer_id)
		multiplayer_id += 1

	Lobby.show_battleground.rpc()

func multiplayer_instantiate(lobby_id: int, idx_character: int, multiplayer_id: int) -> void:
	var is_me := lobby_id == Lobby.get_id()
	var idx_team := 0 if is_me else 1
	if teams[idx_team].lobby_id == -1:
		teams[idx_team].lobby_id = lobby_id

	var char_arr := multiplayer_me.characters if is_me else multiplayer_opponent.characters
	var character: Character = char_arr[idx_character]
	print("%s Instantiate Char %s" % [ "server" if Lobby.is_server() else "client", character.name ])

	var actor: BGActor = ps_rpg_actor.instantiate()
	teams[idx_team].actors.append(actor)
	actor.position.x = -200 if is_me else 200
	actor.character = character

	actor.multiplayer_id = multiplayer_id

	if is_me:
		var hud: BattleHUD = ps_selection_hud.instantiate()
		hud.populate_action_list(character)
		_huds.add_child(hud)
		actor.selector = hud.selector
	elif Lobby.is_server():
		var ps: PeerSelector = ps_peer_selector.instantiate()
		ps.peer_id = lobby_id
		_huds.add_child(ps)
		actor.selector = ps.selector

	_actors.add_child(actor)

	actor.update_character_ui()
	actors_by_multiplayer_id[multiplayer_id] = actor

func client_selection(sender: int, me_: int, allies_: Array[int], opponents_: Array[int]) -> void:
	var me: BGActor = actors_by_multiplayer_id[me_]
	var allies: Array[BGActor] = []
	var opponents: Array[BGActor] = []
	for id in allies_:
		allies.append(actors_by_multiplayer_id[id])
	for id in opponents_:
		opponents.append(actors_by_multiplayer_id[id])

	var params := await me.make_choice(allies, opponents)
	var target := -1
	var action := ""
	if len(params) == 2:
		target = (params[0] as BGActor).multiplayer_id
		action = (params[1] as Action).resource_path

	Lobby.client_action_selected.rpc_id(sender, target, action)

func update_battle_state(state: Dictionary) -> void:
	for multiplayer_id: int in state:
		var bga: BGActor = actors_by_multiplayer_id[multiplayer_id]
		bga.character.health = state[multiplayer_id].health
		bga.update_character_ui()


func end_multiplayer_battle(winner_id: int, losers_ids: Array[int]) -> void:
	var winner: Team = null
	var losers: Array[Team] = []
	for team in teams:
		if winner == null and team.lobby_id == winner_id:
			winner = team
		else:
			losers.append(team)

	_end_multiplayer_battle(winner, losers)

func _clean_up_battleground() -> void:
	hide()
	teams = []
	for c: Node in _actors.get_children() + _huds.get_children():
		c.queue_free()
	Game.enter_overworld()

func _end_battle(winner: Team, losers: Array[Team]) -> void:
	if in_multiplayer:
		return

	for loser in losers:
		for actor in loser.actors:
			if actor.is_in_group("player"):
				get_tree().quit()

	_clean_up_battleground()

func _end_multiplayer_battle(winner: Team, losers: Array[Team]) -> void:
	if not in_multiplayer:
		return

	in_multiplayer = false

	if Lobby.is_server():
		var loser_ids: Array[int] = []
		for loser in losers:
			loser_ids.append(loser.lobby_id)
		Lobby.send_battle_results.rpc(winner.lobby_id, loser_ids)

	Lobby.leave_lobby.call_deferred()
	_clean_up_battleground()

func _execute_turn() -> void:
	in_turn = true
	# Sort by speed
	var all_actors := _actors.get_children()
	var speed_sorted: Array[BGActor] = []
	for rpga in all_actors:
		if rpga is BGActor:
			speed_sorted.append(rpga as BGActor)

	for rpga: BGActor in speed_sorted:
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
		apply_action(rpga, target, action)

	in_turn = false

func _process(delta: float) -> void:
	if in_multiplayer and not Lobby.is_server():
		return

	if not in_turn:
		_execute_turn()

func apply_action(user: BGActor, target: BGActor, action: Action) -> void:
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
			target.update_health()
			if target.character.health <= 0:
				print("%s has died" % target.name)
				_check_for_battle_end()

		Action.Type.HEALING:
			var heal_points_from_ratio := int(target.character.max_health * action.heal_ratio)
			var to_heal: int = action.health_points if action.health_points else heal_points_from_ratio
			print("Healing %s by %s" % [ target.character.name, to_heal ])
			target.character.health = min(target.character.max_health,
										  target.character.health + to_heal)
			target.update_health()

	if not in_multiplayer:
		return

	var state := _serialise_battle_state()
	Lobby.update_battle_state.rpc(state)

func _check_for_battle_end() -> void:
	var is_dead := func (actor: BGActor) -> bool:
		return actor.character.health <= 0

	var winner: Team
	var losers: Array[Team] = []
	for team: Team in teams:
		if team.actors.all(is_dead):
			winner = team
		else:
			losers.append(team)

	if in_multiplayer:
		_end_multiplayer_battle(winner, losers)
	else:
		_end_battle(winner, losers)

func _serialise_battle_state() -> Dictionary:
	var state := {}
	for bga: BGActor in _actors.get_children():
		state[bga.multiplayer_id] = { health = bga.character.health }
	return state
