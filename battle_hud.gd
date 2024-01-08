class_name BattleHUD
extends Control

signal action_selected(action)

const ps_action_entry := preload("res://ActionEntry.tscn")

@export var attack_button: Button
@export var skip_button: Button
@export var action_list: Control

@onready var view_main := $UI/Main
@onready var view_command_list := $UI/CommandList

func _ready() -> void:
	_hide()

func populate_action_list(lib: ActionLibrary) -> void:
	for action in lib.actions:
		var entry: ActionEntry = ps_action_entry.instantiate()
		entry.fill(action)
		action_list.add_child(entry)
		entry.action_entry_selected.connect(self._on_action_entry_selected)

func _on_rpg_actor_selection_started() -> void:
	_show()

func _on_ac_attack_pressed():
	view_main.hide()
	view_command_list.show()

func _on_ac_skip_pressed():
	action_selected.emit()
	_hide()

func _on_action_entry_selected(action: Action) -> void:
	action_selected.emit(action)
	_hide()


func _show() -> void:
	position.x = 0
	attack_button.mouse_filter = Control.MOUSE_FILTER_STOP
	skip_button.mouse_filter = Control.MOUSE_FILTER_STOP

	view_main.show()
	view_command_list.hide()

func _hide() -> void:
	position.x = size.x * 2
	attack_button.mouse_filter = Control.MOUSE_FILTER_PASS
	skip_button.mouse_filter = Control.MOUSE_FILTER_PASS
	view_main.hide()
	view_command_list.hide()


func _on_command_list_back_button_pressed() -> void:
	view_main.show()
	view_command_list.hide()
