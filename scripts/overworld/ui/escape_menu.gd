class_name Menu
extends Control

@export var ip_field: TextEdit

@onready var _animator := $AnimationPlayer

func open() -> void:
	_animator.play("show")

func close() -> void:
	_animator.play("hide")

func _on_create_lobby():
	pass # Replace with function body.


func _on_join_lobby():
	pass # Replace with function body.
