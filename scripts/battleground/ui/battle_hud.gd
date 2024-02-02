class_name BattleHUD
extends Control
## A HUD for selecting the actions and targets of a player controlled [BGActor]

const ps_action_entry := preload("res://battlegrounds/ui/ActionEntry.tscn")

## The [SelectorInterface] for the HUD
@onready var selector := $Selector

@export var attack_button: Button
@export var skip_button: Button
@export var action_list: Control

@onready var display_name := $UI/CharacterName
@onready var view_main := $UI/Menus/Main
@onready var view_command_list := $UI/Menus/CommandList
@onready var view_select_target := $UI/Menus/SelectTarget

var _selected_action: Action = null
var _target: BGActor = null

var _me: BGActor
var _allies: Array[BGActor]
var _opponents: Array[BGActor]

## Opens the HUD and connects the [signal BGActor.body_selected] on all the passed
## actors to this HUD
func open_hud(me: BGActor, allies: Array[BGActor], opponents: Array[BGActor]) -> void:
	_show()
	display_name.text = me.name
	_me = me
	_allies = allies
	_opponents = opponents
	for rpg_actor in [ _me ] + _allies + _opponents:
		rpg_actor.body_selected.connect(self._on_rpg_actor_body_selected)

## Closes the HUD, disconnecting [signal BGActor.body_selected] on all actors
func close_hud() -> void:
	_hide()
	for rpg_actor in [ _me ] + _allies + _opponents:
		rpg_actor.body_selected.disconnect(self._on_rpg_actor_body_selected)
	_me = null
	_allies = []
	_opponents = []
#
	_selected_action = null
	_target = null

## Fills the action list with the [member Character.actions] from [param character]
func populate_action_list(character: Character) -> void:
	for action in character.actions:
		var entry: ActionEntry = ps_action_entry.instantiate()
		entry.fill(action)
		action_list.add_child(entry)
		entry.action_entry_selected.connect(self._on_action_entry_selected)

func _ready() -> void:
	_hide()

func _on_ac_attack_pressed():
	view_main.hide()
	view_command_list.show()
	view_select_target.hide()

func _on_ac_skip_pressed():
	selector.action_selected.emit()
	close_hud()

func _on_action_entry_selected(action: Action) -> void:
	if action.targets == Action.Target.SELF:
		_submit_action(action, _me)
		return

	_selected_action = action
	view_main.hide()
	view_command_list.hide()
	view_select_target.show()

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

func _submit_action(action: Action, target: BGActor) -> void:
	match action.targets:
		Action.Target.ALLIES:
			if not target in _allies:
				return
		Action.Target.OPPONENTS:
			if not target in _opponents:
				return
		Action.Target.SELF:
			if target != _me:
				return
		Action.Target.NOT_SELF:
			if target == _me:
				return

	selector.action_selected.emit(target, action)
	close_hud()

func _on_rpg_actor_body_selected(actor: BGActor) -> void:
	if not _selected_action:
		return

	_submit_action(_selected_action, actor)
