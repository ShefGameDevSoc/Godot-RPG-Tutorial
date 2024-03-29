class_name Character
## A representation of the stats of a character

var name: String

var actions: Array[Action]

var max_health := 200
var health := 200
var attack := 40
var defense := 50
var speed := 100

## Serialises this character in a [Dictionary]
##
## Primarily used to send this character's data over a network
func to_dict() -> Dictionary:
	var actions_as_paths: Array[String] = []
	for action in actions:
		actions_as_paths.append(action.resource_path)

	return {
		name = name, actions = actions_as_paths,
		max_health = max_health, health = health,
		attack = attack, defense = defense, speed = speed
	}

## Deserialises a character from a [Dictionary]
##
## Primarily used for using character data passed over a network
static func from_dict(dict: Dictionary) -> Character:
	var character := Character.new()
	character.name = dict.name
	character.max_health = int(dict.max_health)
	character.health = int(dict.health)
	character.attack = int(dict.attack)
	character.defense = int(dict.defense)
	character.speed = int(dict.speed)

	for path in dict.actions:
		character.actions.append(load(path))

	return character

func _to_string() -> String:
	return "Char %s: HP %d/%d Atk %d Def %d Spd %d" % [name, health, max_health, attack, defense, speed]
