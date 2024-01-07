extends Node2D

const ps_rpg_actor := preload("res://RPGActor.tscn")
const ps_selection_hud := preload("res://BattleHUD.tscn")

@onready var _actors := $Actors
@onready var _huds := $HUDs

var in_turn: bool = false

func _ready() -> void:
	for i in 1:
		var actor: RPGActor = ps_rpg_actor.instantiate()
		var hud: BattleHUD = ps_selection_hud.instantiate()
		_actors.add_child(actor)
		_huds.add_child(hud)
		
		actor.selector = hud
		actor.action_selection_started.connect(hud._on_rpg_actor_selection_started)
		
	for i in 1:
		var actor: RPGActor = ps_rpg_actor.instantiate()
		var hud: BattleHUD = ps_selection_hud.instantiate()
		_actors.add_child(actor)
		_huds.add_child(hud)
		
		actor.action_selection_started.connect(hud._on_rpg_actor_selection_started)

func _execute_turn() -> void:
	in_turn = true
	# Sort by speed
	var speed_sorted := _actors.get_children()
	
	for rpga in speed_sorted:
		print(rpga.name)
		await rpga.make_choice()

func _process(delta: float) -> void:
	if not in_turn:
		_execute_turn()
	pass
