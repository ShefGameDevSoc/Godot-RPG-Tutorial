class_name BattleHUD
extends Control
## A HUD for selecting the actions and targets of a player controlled [BGActor]

## The [SelectorInterface] for the HUD
@onready var selector := $Selector

@export var attack_button: Button
@export var skip_button: Button
@export var action_list: Control

@onready var display_name := $UI/CharacterName
@onready var view_main := $UI/Menus/Main
@onready var view_command_list := $UI/Menus/CommandList
@onready var view_select_target := $UI/Menus/SelectTarget

## Opens the HUD and connects the [signal BGActor.body_selected] on all the passed
## actors to this HUD
func open_hud(me: BGActor, allies: Array[BGActor], opponents: Array[BGActor]) -> void:
	_show()

## Closes the HUD, disconnecting [signal BGActor.body_selected] on all actors
func close_hud() -> void:
	_hide()

## Fills the action list with the [member Character.actions] from [param character]
func populate_action_list(character: Character) -> void:
	pass

func _ready() -> void:
	_hide()

func _on_ac_attack_pressed():
	view_main.hide()
	view_command_list.show()
	view_select_target.hide()

func _on_ac_skip_pressed():
	selector.action_selected.emit([])
	close_hud()

func _show() -> void:
	position.x = 0
	attack_button.mouse_filter = Control.MOUSE_FILTER_STOP
	skip_button.mouse_filter = Control.MOUSE_FILTER_STOP

	view_main.show()
	view_command_list.hide()
	view_select_target.hide()

func _hide() -> void:
	position.x = size.x * 2
	attack_button.mouse_filter = Control.MOUSE_FILTER_PASS
	skip_button.mouse_filter = Control.MOUSE_FILTER_PASS
	view_main.hide()
	view_command_list.hide()
	view_select_target.hide()

func _on_command_list_back_button_pressed() -> void:
	view_main.show()
	view_command_list.hide()
	view_select_target.hide()

func _on_select_target_back_pressed():
	view_main.hide()
	view_command_list.show()
	view_select_target.hide()

func _on_action_entry_selected(action: Action) -> void:
	pass

func _submit_action(action: Action, target: BGActor) -> void:
	pass

func _on_rpg_actor_body_selected(actor: BGActor) -> void:
	pass
