class_name PeerBattler
## Represents a peer from the lobby

var id: int
var name: String
var characters: Array[Character]

func _init(_id: int, _name: String, _characters: Array[Character]) -> void:
	id = _id
	name = _name
	characters = _characters
