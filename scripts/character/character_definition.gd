class_name CharacterDefinition
extends Resource
## Defines a blueprint for a [Character] to be generated from
##
## Defines baseline values for the various stats and ranges for these stats to exist in
## When a new [Character] is wanted it creates one with stats randomly within the ranges defined

@export var _name: String

@export var _actions: Array[Action]

@export var _health :=  160
@export var _health_vicinity := 10

@export var _attack := 60
@export var _attack_vicinity := 7

@export var _defense := 50
@export var _defense_vicinity := 14

@export var _speed := 100
@export var _speed_vicinity := 20

## Creates a new [Character]
func create(rng: RandomNumberGenerator) -> Character:
	var c := Character.new()
	c.actions = _actions
	c.name = String(_name) + str(rng.randi() % 1000)
	c.max_health = _random_in_vicinity(rng, _health, _health_vicinity)
	c.health = c.max_health
	c.attack = _random_in_vicinity(rng, _attack, _attack_vicinity)
	c.defense = _random_in_vicinity(rng, _defense, _defense_vicinity)
	c.speed = _random_in_vicinity(rng, _speed, _speed_vicinity)
	return c

func _random_in_vicinity(rng: RandomNumberGenerator, value: int, vicinity: int) -> int:
	var min := value - vicinity
	var max := value + vicinity
	return max(rng.randi_range(min, max), 1)
