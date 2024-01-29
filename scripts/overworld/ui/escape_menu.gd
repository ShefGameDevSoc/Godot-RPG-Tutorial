class_name Menu
extends Control

@export var ip_field: TextEdit

@onready var _animator := $AnimationPlayer

@onready var _name := $UI/UICont/ControlsCont/Name
@onready var _lobby_ip := $UI/UICont/ControlsCont/IPEnter

func open() -> void:
	_animator.play("show")

func close() -> void:
	_animator.play("hide")

func quick_close() -> void:
	_animator.play("hide")
	_animator.seek(1.0)

func _on_create_lobby():
	if _name.text == "":
		return

	var error := Lobby.create_lobby(_name.text)
	if error:
		print("There was an error with setting up the lobby")


func _on_join_lobby():
	if _name.text == "":
		return

	var error := Lobby.join_lobby(_lobby_ip.text, _name.text)
	if error:
		print("Could not join lobby")
