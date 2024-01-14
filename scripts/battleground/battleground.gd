extends Node2D

const ps_rpg_actor := preload("res://actors/battleground/BGActor.tscn")
const ps_selection_hud := preload("res://battlegrounds/ui/BattleHUD.tscn")

@onready var _actors := $Actors
@onready var _huds := $HUDs

var in_turn: bool = false

class Team:
	var actors: Array[BGActor]

var teams: Array[Team] = []

func _ready() -> void:
	var team := Team.new()
	for i in 1:
		var actor: BGActor = ps_rpg_actor.instantiate()
		team.actors.append(actor)
		actor.position.x = -200
		var hud: BattleHUD = ps_selection_hud.instantiate()
		hud.populate_action_list(actor.library)
		_actors.add_child(actor)
		_huds.add_child(hud)

		actor.selector = hud
		actor.action_selection_started.connect(hud.open_hud)

		actor.character = Character.new()
		actor.update_health()

	teams.append(team)
	team = Team.new()

	for i in 1:
		var actor: BGActor = ps_rpg_actor.instantiate()
		team.actors.append(actor)
		actor.position.x = 200
		var hud: BattleHUD = ps_selection_hud.instantiate()
		hud.populate_action_list(actor.library)
		_actors.add_child(actor)
		_huds.add_child(hud)

		actor.selector = hud
		actor.action_selection_started.connect(hud.open_hud)

		actor.character = Character.new()
		actor.character.health = 100
		actor.character.max_health = 100
		actor.character.defense = 40
		actor.update_health()

	teams.append(team)

func _execute_turn() -> void:
	in_turn = true
	# Sort by speed
	var all_actors := _actors.get_children()
	var speed_sorted: Array[BGActor] = []
	for rpga in all_actors:
		if rpga is BGActor:
			speed_sorted.append(rpga as BGActor)

	for rpga in speed_sorted:
		print(rpga.name)
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
	if not in_turn:
		_execute_turn()

func apply_action(user: BGActor, target: BGActor, action: Action) -> void:
	if not action.cannot_miss and float(action.accuracy) < randf() * 100.0:
		return

	match action.type:
		Action.Type.ATTACK:
			# Calculation derived from Pokemon's damage calculations
			# https://bulbapedia.bulbagarden.net/wiki/Damage
			var damage := int(action.power * user.character.attack
						  / target.character.defense * (1.0 - randf() * 0.2))
			print("Dealing %d damage to %s" % [ damage, target.name ])
			target.character.health = max(0, target.character.health - damage)
			target.update_health()
			if target.character.health <= 0:
				print("%s has died" % target.name)

		Action.Type.HEALING:
			var heal_points_from_ratio := int(target.character.max_health * action.heal_ratio)
			var to_heal: int = action.health_points if action.health_points else heal_points_from_ratio
			print("Healing %s by %s" % [ target.name, to_heal ])
			target.character.health = min(target.character.max_health,
										  target.character.health + to_heal)
			target.update_health()
