class_name BattleHUD
extends Control

signal action_selected

@export var attack_button: Button
@export var skip_button: Button

func _ready() -> void:
	_hide()

func populate_action_list(lib: ActionLibrary) -> void:
	pass

func _on_rpg_actor_selection_started() -> void:
	_show()

func _on_ac_attack_pressed():
	action_selected.emit()
	_hide()


func _on_ac_skip_pressed():
	pass # Replace with function body.


func _show() -> void:
	position.x = 0
	attack_button.mouse_filter = Control.MOUSE_FILTER_STOP
	skip_button.mouse_filter = Control.MOUSE_FILTER_STOP

func _hide() -> void:
	position.x = size.x * 2
	attack_button.mouse_filter = Control.MOUSE_FILTER_PASS
	skip_button.mouse_filter = Control.MOUSE_FILTER_PASS
