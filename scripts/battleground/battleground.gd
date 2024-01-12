extends Node2D

const ps_rpg_actor := preload("res://actors/battleground/BGActor.tscn")
const ps_selection_hud := preload("res://battlegrounds/ui/BattleHUD.tscn")

@onready var _actors := $Actors
@onready var _huds := $HUDs

var in_turn: bool = false

func _ready() -> void:
	for i in 1:
		var actor: BGActor = ps_rpg_actor.instantiate()
		actor.position.x = -200
		var hud: BattleHUD = ps_selection_hud.instantiate()
		hud.populate_action_list(actor.library)
		_actors.add_child(actor)
		_huds.add_child(hud)

		actor.selector = hud
		actor.action_selection_started.connect(hud.open_hud)

		actor.character = Character.new()
		actor.update_health()

	for i in 1:
		var actor: BGActor = ps_rpg_actor.instantiate()
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
		var params := await rpga.make_choice(speed_sorted)
		if len(params) == 0:
			continue
		var target: BGActor = params[0]
		var action: Action = params[1]
		_calculate_damage(rpga, target, action)

	in_turn = false

func _process(delta: float) -> void:
	if not in_turn:
		_execute_turn()

func _calculate_damage(user: BGActor, target: BGActor, action: Action) -> void:
	if float(action.accuracy) < randf() * 100.0:
		return

	# Calculation derived from Pokemon's damage calculations
	# https://bulbapedia.bulbagarden.net/wiki/Damage
	var damage := int(action.power * user.character.attack / target.character.defense * (1.0 - randf() * 0.2))
	target.character.health = max(0, target.character.health - damage)
	target.update_health()
	print("Dealing %d damage to %s" % [ damage, target.name ])
	if target.character.health <= 0:
		print("%s has died" % target.name)
