class_name Menu
extends Control

const ps_menu_button := preload("res://overworlds/ui/EscapeMenuButton.tscn")

#@export var ip_field: TextEdit

@onready var _animator := $AnimationPlayer

@onready var _name := $UI/UICont/ControlsCont/Name
@onready var _lobby_ip := $UI/UICont/ControlsCont/ScrCreate/IP
@onready var _ip_entry := $UI/UICont/ControlsCont/ScrJoin/IPEnter

@onready var _screen_home := $UI/UICont/ControlsCont/ScrHome
@onready var _screen_create := $UI/UICont/ControlsCont/ScrCreate
@onready var _screen_join := $UI/UICont/ControlsCont/ScrJoin

#func _ready() -> void:
	#for ip: String in IP.get_local_addresses():
		#if len(ip.split(".")) != 4:
			#continue
#
		#var em_button: EscapeMenuButton = ps_menu_button.instantiate()
		#em_button.text = ip
		#em_button.option = ip
		#em_button.option_selected.connect(self._on_menu_button_pressed)
		#_screen_join.add_child(em_button)

func open() -> void:
	_animator.play("show")
	_name.grab_focus()

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

	var hostname := ""
	match OS.get_name():
		"Windows":
			hostname = str(OS.get_environment("COMPUTERNAME"))
		"macOS":
			hostname = str(OS.get_environment("HOSTNAME"))
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			hostname = str(OS.get_environment("HOSTNAME"))
		"Android":
			print("Android")
		"iOS":
			print("iOS")
		"Web":
			print("Web")

	_lobby_ip.text = IP.resolve_hostname(hostname, IP.TYPE_IPV4)
	_screen_home.hide()
	_screen_create.show()
	_screen_join.hide()


func _on_join_lobby():
	_screen_home.hide()
	_screen_create.hide()
	_screen_join.show()
	#if _name.text == "":
		#return
#
	#var error := Lobby.join_lobby(_lobby_ip.text, _name.text)
	#if error:
		#print("Could not join lobby")

func _on_name_text_changed() -> void:
	_filter_text_edit(_name)

func _on_ip_enter_text_changed() -> void:
	_filter_text_edit(_ip_entry, true)

func _filter_text_edit(te: TextEdit, no_alpha := false) -> void:
	var regex := RegEx.new()
	regex.compile("[0-9\\.]")

	var filtered_text := ""
	for c in te.text:
		if c == "\n" or c == "\r" or (no_alpha and not regex.search(c)):
			continue
		if c == "\t":
			filtered_text += " "
		else:
			filtered_text += c
	te.text = filtered_text
	te.set_caret_column(len(filtered_text))

func _on_menu_button_pressed(option: String) -> void:
	if _name.text == "":
		return

	var error := Lobby.join_lobby(option, _name.text)
	if error:
		print("Could not join lobby")

func _on_back_pressed() -> void:
	_screen_home.show()
	_screen_create.hide()
	_screen_join.hide()
	_name.grab_focus()
	Lobby.cancel_lobby()
