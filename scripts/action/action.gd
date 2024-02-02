class_name Action
extends Resource
## Defines an action taht can be taken in battle

enum Target { EVERYONE, ALLIES, OPPONENTS, SELF, NOT_SELF }
enum Type { ATTACK, HEALING }

@export var name: String = "New Action"
@export var targets := Target.NOT_SELF
@export var type := Type.ATTACK

@export var cannot_miss := false
@export_range(0, 100) var accuracy: int = 100

@export_group("Attack")
@export var power: int = 50

@export_group("Heal")
## Should we heal by points or by percentage?
@export var heal_by_points := true
## The number HP to heal
@export var health_points: int
## The proportion of the target's health to heal
@export_range(0.0, 1.0) var heal_ratio: float
